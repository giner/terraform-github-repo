resource "github_repository" "this" {
  name = var.repo_name

  description          = var.repo_config.description
  visibility           = var.repo_config.visibility
  vulnerability_alerts = var.repo_config.vulnerability_alerts

  allow_auto_merge       = var.repo_config.allow_auto_merge
  allow_merge_commit     = var.repo_config.allow_merge_commit
  allow_rebase_merge     = var.repo_config.allow_rebase_merge
  allow_squash_merge     = var.repo_config.allow_squash_merge
  allow_update_branch    = var.repo_config.allow_update_branch
  archive_on_destroy     = var.repo_config.archive_on_destroy
  auto_init              = var.repo_config.auto_init
  delete_branch_on_merge = var.repo_config.delete_branch_on_merge
  has_discussions        = var.repo_config.has_discussions
  has_downloads          = var.repo_config.has_downloads
  has_issues             = var.repo_config.has_issues
  has_projects           = var.repo_config.has_projects
  has_wiki               = var.repo_config.has_wiki

  web_commit_signoff_required = var.repo_config.web_commit_signoff_required

  dynamic "pages" {
    for_each = var.repo_config.pages != null ? [1] : []

    content {
      build_type = var.repo_config.pages.build_type
      cname      = var.repo_config.pages.cname

      dynamic "source" {
        for_each = var.repo_config.pages.source != null ? [1] : []

        content {
          branch = var.repo_config.pages.source.branch
          path   = var.repo_config.pages.source.path
        }
      }
    }
  }
}

resource "github_branch" "this" {
  for_each = var.repo_config.branches

  repository    = github_repository.this.name
  branch        = each.key
  source_branch = var.organization_default_branch
}

resource "github_branch_default" "this" {
  repository = github_repository.this.name
  branch     = github_branch.this[var.repo_config.default_branch].branch
}

resource "github_repository_collaborator" "this" {
  for_each = {
    for user, perm in var.repo_config.users : user => {
      user = user
      perm = perm
    }
  }

  repository = github_repository.this.name
  username   = each.value.user
  permission = each.value.perm
}

resource "github_team_repository" "this" {
  for_each = {
    for team, perm in var.repo_config.teams : team => {
      team = team
      perm = perm
    }
  }

  team_id    = can(tonumber(each.value.team)) ? each.value.team : data.github_team.this[each.value.team].id
  repository = github_repository.this.name
  permission = each.value.perm
}

resource "github_repository_file" "branch_file" {
  for_each = {
    for branch_name, _ in var.repo_config.branches : branch_name => {
      branch = branch_name
      file   = var.repo_config.branch_file
    } if var.repo_config.branch_file_enabled
  }

  repository     = github_repository.this.name
  branch         = github_branch.this[each.key].branch
  file           = each.value.file
  content        = "${github_branch.this[each.key].branch}\n"
  commit_message = "Managed by Terraform (github_repo: branch_file ${each.value.file})"

  depends_on = [github_branch_protection.this]
}

resource "github_branch_protection" "this" {
  for_each = {
    for branch_name, branch_config in var.repo_config.branches : branch_name => merge(
      branch_config,
      {
        branch         = branch_name
        enforce_admins = var.enforce_admins_enabled ? branch_config.enforce_admins : false
      }
    ) if branch_config.branch_protection_enabled
  }

  repository_id = github_repository.this.node_id # Use of `node_id` instead of `id` or `name` is a workaround for terraform import, see https://github.com/integrations/terraform-provider-github/issues/622

  pattern                         = each.value.branch
  enforce_admins                  = each.value.enforce_admins
  allows_deletions                = each.value.allow_deletions
  allows_force_pushes             = each.value.allow_force_pushes
  require_conversation_resolution = each.value.require_conversation_resolution

  required_pull_request_reviews {
    dismiss_stale_reviews           = each.value.dismiss_stale_reviews
    required_approving_review_count = each.value.required_approving_review_count
    require_code_owner_reviews      = each.value.require_code_owner_reviews
  }

  dynamic "required_status_checks" {
    for_each = each.value.required_status_checks_enabled ? [1] : []

    content {
      strict   = each.value.required_status_checks.strict
      contexts = each.value.required_status_checks.contexts
    }
  }
}

resource "github_repository_autolink_reference" "this" {
  count = var.repo_config.autolink != null ? 1 : 0

  repository          = github_repository.this.name
  key_prefix          = var.repo_config.autolink.key_prefix
  target_url_template = var.repo_config.autolink.url_template
}

resource "github_app_installation_repository" "this" {
  for_each = var.repo_config.apps

  installation_id = each.value.installation_id
  repository      = github_repository.this.name
}

data "github_team" "this" {
  for_each = toset([for team, _ in var.repo_config.teams : team if !can(tonumber(team))])

  slug = each.key

  summary_only = true
}

resource "github_repository_deploy_key" "this" {
  for_each = {
    for deploy_key in var.repo_config.deploy_keys : deploy_key.title => {
      title     = deploy_key.title
      key       = deploy_key.key
      read_only = deploy_key.read_only
    }
  }

  repository = github_repository.this.name
  title      = each.value.title
  key        = each.value.key
  read_only  = each.value.read_only
}

resource "github_actions_secret" "this" {
  for_each = {
    for name, value in var.repo_config.secrets : name => {
      name  = name
      value = value
    }
  }

  repository      = github_repository.this.name
  secret_name     = each.value.name
  plaintext_value = each.value.value
}
