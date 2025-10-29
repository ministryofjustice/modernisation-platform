locals {
  base_topics   = ["modernisation-platform", "civil-service"]
  module_topics = ["terraform-module"]
  topics        = var.type == "core" ? local.base_topics : concat(local.base_topics, local.module_topics)
}

# Repository basics
resource "github_repository" "default" {
  name                        = var.name
  description                 = join(" • ", [var.description, "This repository is defined and managed in Terraform"])
  allow_merge_commit          = true
  allow_squash_merge          = true
  allow_rebase_merge          = true
  allow_update_branch         = true
  archived                    = false
  archive_on_destroy          = true
  auto_init                   = false
  delete_branch_on_merge      = true
  has_issues                  = true
  has_projects                = true
  has_wiki                    = var.type == "core" ? true : false
  has_downloads               = true
  homepage_url                = var.homepage_url
  is_template                 = var.type == "template" ? true : false
  squash_merge_commit_title   = var.squash_merge_commit_message == true ? "PR_TITLE" : null
  squash_merge_commit_message = var.squash_merge_commit_title == true ? "COMMIT_MESSAGES" : null
  topics                      = concat(local.topics, var.topics)
  visibility                  = var.visibility
  vulnerability_alerts        = true

  security_and_analysis {
    dynamic "advanced_security" {
      for_each = var.visibility == "public" ? [] : [1]
      content {
        status = "enabled"
      }
    }

    secret_scanning {
      status = "enabled"
    }

    secret_scanning_push_protection {
      status = "enabled"
    }
  }

  template {
    owner      = "ministryofjustice"
    repository = var.type == "module" ? "modernisation-platform-terraform-module-template" : "template-repository"
  }

  # The `pages.source` block doesn't support dynamic blocks in GitHub provider version 4.3.2,
  # so we ignore the changes so it doesn't try to revert repositories that have manually set
  # their pages configuration.
  lifecycle {
    ignore_changes = [template, pages]
  }
}

resource "null_resource" "push_protection_bypass" {
  count = var.enable_push_protection_bypass ? 1 : 0
  provisioner "local-exec" {
    command = <<EOT
      curl -s -X PATCH \
        -H "Authorization: token ${var.github_token}" \
        -H "Accept: application/vnd.github+json" \
        https://api.github.com/repos/${var.github_org}/${var.name}/security-and-analysis \
        -d '{
          "security_and_analysis": {
            "secret_scanning": {"status": "enabled"},
            "secret_scanning_push_protection": {
              "status": "enabled",
              "bypass_actors": [
                {
                  "type": "RepositoryRole",
                  "role_name": "Admin"
                }
              ]
            }
          }
        }'
    EOT
    interpreter = ["/bin/bash", "-c"]
  }

  triggers = {
    repo_name = var.name
  }

  depends_on = [github_repository.default]
}

resource "github_branch_protection" "default" {
  #checkov:skip=CKV_GIT_6:"Following discussions with other teams we will not be enforcing signed commits currently"
  repository_id  = github_repository.default.id
  pattern        = "main"
  enforce_admins = true
  #tfsec:ignore:github-branch_protections-require_signed_commits
  require_signed_commits = var.name == "modernisation-platform-environments" ? false : true

  required_status_checks {
    strict   = false
    contexts = var.required_checks
  }

  #checkov:skip=CKV_GIT_5:"moj branch protection guidelines do not require 2 reviews"
  required_pull_request_reviews {
    dismiss_stale_reviews           = true
    require_code_owner_reviews      = true
    required_approving_review_count = 1
    restrict_dismissals             = var.restrict_dismissals
    dismissal_restrictions          = var.dismissal_restrictions
  }
}

resource "github_repository_ruleset" "default" {
  repository  = github_repository.default.id
  name        = "Tag Protection Ruleset"
  enforcement = "active"
  target      = "tag"

  conditions {
    ref_name {
      include = ["~ALL"]
      exclude = []
    }
  }

  bypass_actors {
    actor_id    = 1
    actor_type  = "OrganizationAdmin"
    bypass_mode = "always"
  }

  bypass_actors {
    actor_id    = 2
    actor_type  = "RepositoryRole"
    bypass_mode = "always"
  }

  bypass_actors {
    actor_id    = 5
    actor_type  = "RepositoryRole"
    bypass_mode = "always"
  }

  rules {
    creation            = true
    update              = true
    deletion            = true
    required_signatures = true
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
