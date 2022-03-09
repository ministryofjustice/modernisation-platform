locals {
  base_topics   = ["modernisation-platform", "civil-service"]
  module_topics = ["terraform-module"]
  topics        = var.type == "core" ? local.base_topics : concat(local.base_topics, local.module_topics)
}

# Repository basics
resource "github_repository" "default" {
  name                   = var.name
  description            = join(" • ", [var.description, "This repository is defined and managed in Terraform"])
  homepage_url           = var.homepage_url
  visibility             = var.visibility
  has_issues             = var.type == "core" ? true : false
  has_projects           = var.type == "core" ? true : false
  has_wiki               = var.type == "core" ? true : false
  has_downloads          = true
  is_template            = false
  allow_merge_commit     = true
  allow_squash_merge     = true
  allow_rebase_merge     = true
  delete_branch_on_merge = true
  auto_init              = false
  archived               = false
  archive_on_destroy     = true
  vulnerability_alerts   = true
  topics                 = concat(local.topics, var.topics)

  template {
    owner      = "ministryofjustice"
    repository = "template-repository"
  }

  # The `pages.source` block doesn't support dynamic blocks in GitHub provider version 4.3.2,
  # so we ignore the changes so it doesn't try to revert repositories that have manually set
  # their pages configuration.
  lifecycle {
    ignore_changes = [template, pages]
  }
}

resource "github_branch_protection" "default" {
  repository_id          = github_repository.default.id
  pattern                = "main"
  enforce_admins         = true
  require_signed_commits = false

  required_status_checks {
    strict   = true
    contexts = var.required_checks
  }

  required_pull_request_reviews {
    dismiss_stale_reviews           = true
    require_code_owner_reviews      = true
    required_approving_review_count = 1
  }
}

# Secrets
data "github_actions_public_key" "default" {
  repository = github_repository.default.id
}

resource "github_actions_secret" "default" {
  #checkov:skip=CKV_GIT_4:Although secrets are provided in plaintext, they are encrypted at rest
  for_each        = var.secrets
  repository      = github_repository.default.id
  secret_name     = each.key
  plaintext_value = each.value
}
