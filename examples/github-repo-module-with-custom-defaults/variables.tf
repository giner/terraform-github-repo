variable "organization_default_branch" {
  type        = string
  description = "The default branch for the organization should be different from the default branch for a repository to avoid conflicts"
  default     = "default"
}

variable "enforce_admins_enabled" {
  type    = bool
  default = true
}

variable "repo_name" {
  type = string
}

variable "repo_config" {
  type = object({
    description    = optional(string)
    default_branch = optional(string)

    visibility           = optional(string, "private")
    vulnerability_alerts = optional(bool, true)

    allow_merge_commit     = optional(bool)
    allow_rebase_merge     = optional(bool)
    allow_squash_merge     = optional(bool)
    allow_update_branch    = optional(bool)
    archive_on_destroy     = optional(bool, true)
    auto_init              = optional(bool)
    delete_branch_on_merge = optional(bool, true)
    has_downloads          = optional(bool)
    has_issues             = optional(bool)
    has_projects           = optional(bool)
    has_wiki               = optional(bool)

    web_commit_signoff_required = optional(bool, true)

    branch_file_enabled = optional(bool)
    branch_file         = optional(string)

    branches = optional(map(object({
      branch_protection_enabled = optional(bool)

      allow_deletions                 = optional(bool, false)
      allow_force_pushes              = optional(bool, false)
      dismiss_stale_reviews           = optional(bool, true)
      enforce_admins                  = optional(bool, true)
      require_code_owner_reviews      = optional(bool, true)
      require_conversation_resolution = optional(bool, true)
      required_approving_review_count = optional(number, 1)

      required_status_checks_enabled = optional(bool, true)
      required_status_checks = optional(object({
        strict = optional(bool, true)
      }), {})

      files = optional(list(object({
        file    = string
        content = string
      })), [])
    })), {})

    # NOTE: Values for this list must be passed as sensitive
    deploy_keys = optional(list(object({
      title     = string
      key       = string
      read_only = bool
    })), [])

    secrets = optional(map(string), {}) # NOTE: Values for this map must be passed as sensitive

    apps = optional(map(object({
      installation_id = number
    })), {})

    autolink = optional(object({
      key_prefix   = string
      url_template = string
    }))

    users  = optional(map(string), {})
    groups = optional(map(string), {}) # NOTE: not implemented
    teams  = optional(map(string), {}) # NOTE: numerical team names are treated as team ids
  })
}
