module "github_repo" {
  source = "git::https://github.com/giner/terraform-github-repo?ref=367fa164b7f3bb6ec7d55de039867a5e5dcf031a" # 1.7.0

  organization_default_branch = var.organization_default_branch

  repo_name   = var.repo_name
  repo_config = var.repo_config

  enforce_admins_enabled = var.enforce_admins_enabled
}
