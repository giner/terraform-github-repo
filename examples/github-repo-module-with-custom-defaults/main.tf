module "github_repo" {
  source = "git::https://github.com/giner/terraform-github-repo?ref=8ec58a0efa2b7b4dcc155f620acccb6045008513" # 1.6.0

  organization_default_branch = var.organization_default_branch

  repo_name   = var.repo_name
  repo_config = var.repo_config

  enforce_admins_enabled = var.enforce_admins_enabled
}
