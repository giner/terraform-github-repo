module "github_repo" {
  source = "git::https://github.com/giner/terraform-github-repo?ref=f8921369ea3deb3fcc085fc8649f94fd671f9d96" # 1.1.0

  organization_default_branch = var.organization_default_branch

  repo_name   = var.repo_name
  repo_config = var.repo_config

  enforce_admins_enabled = var.enforce_admins_enabled
}
