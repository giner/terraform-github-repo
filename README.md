# Terraform module to configure a GitHub repository within an organization

Note that personal accounts are not supported by this module.

Requires a personal [token](https://github.com/settings/tokens) with the following permissions:
- repo
- read:org
- read:discussion
- workflow (optional)
- delete_repo (optional)

## How to run

    export GITHUB_TOKEN=$(command to get a token from some secret store)
    terraform apply --var enforce_admins_enabled=false  # This is only needed when expecting changes in branch files or workflows
    terraform apply

## Example

See [variables.tf](variables.tf) for configuration options

```terraform
locals {
  organization_default_branch = "default" # Must match the default branch of the organization

  repos = {
    super-project = {
      description    = "My super project"
      default_branch = "develop"

      branches = {
        develop              = {}
        "release/stable-1.x" = {}
      }
    }
  }
}

provider "github" {
  owner = "your-organization"
}

module "github_repo" {
  source = "git::https://github.com/giner/terraform-github-repo?ref=GIT_COMMIT_ID"

  for_each = local.repos

  organization_default_branch = local.organization_default_branch
  repo_name                   = each.key
  repo_config                 = each.value
}

terraform {
  required_providers {
    github = {
      source = "integrations/github"
    }
  }
}
```
