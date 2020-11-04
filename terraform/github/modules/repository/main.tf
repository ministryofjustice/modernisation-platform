locals {
  base_topics   = ["modernisation-platform", "civil-service"]
  module_topics = ["terraform-module"]
  topics        = var.type == "core" ? local.base_topics : concat(local.base_topics, local.module_topics)
}

resource "github_repository" "default" {
  name                   = var.name
  description            = join(" — ", [var.description, "This repository is defined and managed in Terraform."])
  homepage_url           = var.homepage_url
  visibility             = "public"
  has_issues             = var.type == "core" ? true : false
  has_projects           = var.type == "core" ? true : false
  has_wiki               = var.type == "core" ? true : false
  is_template            = false
  allow_merge_commit     = true
  allow_squash_merge     = true
  allow_rebase_merge     = true
  delete_branch_on_merge = true
  has_downloads          = true
  auto_init              = false
  archived               = false
  topics                 = concat(local.topics, var.topics)

  template {
    owner      = "ministryofjustice"
    repository = "template-repository"
  }

  lifecycle {
    ignore_changes = [template]
  }
}

resource "github_branch_protection" "default" {
  repository             = github_repository.default.id
  branch                 = "main"
  enforce_admins         = true
  require_signed_commits = true

  required_status_checks {
    strict   = true
    contexts = ["format-code"] # format-code is from the template repository
  }

  required_pull_request_reviews {
    dismiss_stale_reviews           = true
    required_approving_review_count = 1
  }
}
