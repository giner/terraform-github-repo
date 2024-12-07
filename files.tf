resource "github_repository_file" "file" {
  for_each = merge(flatten([
    for branch_name, branch_config in var.repo_config.branches : {
      for file in branch_config.files : "${branch_name}_${file.file}" => merge(file, {
        branch = branch_name
      })
    }
  ])...)

  repository          = github_repository.this.name
  branch              = each.value.branch
  file                = each.value.file
  content             = each.value.content
  commit_message      = "Managed by Terraform (github_repo: file ${each.value.file})"
  overwrite_on_create = true

  depends_on = [github_branch_protection.this]
}
