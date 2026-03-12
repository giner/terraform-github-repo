module "github_repo" {
  source = "git::https://github.com/giner/terraform-github-repo?ref=4ecfc3d766f20c293858da990a8b8cf5fb7ceffa" # 1.8.0

  organization_default_branch = var.organization_default_branch

  repo_name   = var.repo_name
  repo_config = var.repo_config

  enforce_admins_enabled = var.enforce_admins_enabled
}
