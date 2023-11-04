data "aws_organizations_organization" "root_account" {}

data "aws_caller_identity" "current" {}

data "aws_caller_identity" "modernisation-platform" {
  provider = aws.modernisation-platform
}

locals {
  application_name           = "core-shared-services"
  environment_management     = jsondecode(data.aws_secretsmanager_secret_version.environment_management.secret_string)
  pagerduty_integration_keys = jsondecode(data.aws_secretsmanager_secret_version.pagerduty_integration_keys.secret_string)

  root_account = data.aws_organizations_organization.root_account

  # This takes the name of the Terraform workspace (e.g. core-vpc-production), strips out the application name (e.g. core-vpc), and checks if
  # the string leftover is `-production`, if it isn't (e.g. core-vpc-non-production => -non-production) then it sets the var to false.
  is-production = substr(terraform.workspace, length(local.application_name), length(terraform.workspace)) == "-production"

  # This produces a distinct list of business units after reading all the JSON files in the environments directory
  environment_files = [
    for file in fileset("../../../environments", "*.json") :
    merge({ name = replace(file, ".json", "") }, jsondecode(file("../../../environments/${file}")))
  ]

  environment = {
    business_units = distinct([
    for member in local.environment_files : lower(member.tags.business-unit)])
    members = flatten([
      for member in local.environment_files : [
        for application in member.environments : {
          account_name  = lower(format("%s-%s", member.name, application.name))
          business_unit = lower(member.tags.business-unit)
      }]
    ])
  }

  business_units = local.environment.business_units

  business_units_with_accounts = {
    for business_unit in local.environment.business_units :
    business_unit => [
      for member in local.environment.members : member.account_name
      if member.business_unit == business_unit
    ]
  }

  tags = {
    business-unit = "Platforms"
    application   = "Modernisation Platform: ${terraform.workspace}"
    is-production = local.is-production
    owner         = "Modernisation Platform: modernisation-platform@digital.justice.gov.uk"
  }
}

locals {
      ecr_repositories = {

    performance-hub = {
      push_principals = [
        "arn:aws:iam::${local.environment_management.account_ids["performance-hub-development"]}:role/modernisation-platform-oidc-cicd",
        "arn:aws:iam::${local.environment_management.account_ids["performance-hub-preproduction"]}:role/modernisation-platform-oidc-cicd",
        "arn:aws:iam::${local.environment_management.account_ids["performance-hub-production"]}:role/modernisation-platform-oidc-cicd"
      ]

      pull_principals = [
        local.environment_management.account_ids["performance-hub-development"],
        local.environment_management.account_ids["performance-hub-preproduction"],
        local.environment_management.account_ids["performance-hub-production"]
      ]

      # Tags
      tags_common = local.tags
    }

    mlra = {
      push_principals = [
        "arn:aws:iam::${local.environment_management.account_ids["mlra-development"]}:user/cicd-member-user",
        local.environment_management.account_ids["mlra-development"]
      ]

      pull_principals = [
        "arn:aws:iam::${local.environment_management.account_ids["mlra-development"]}:user/cicd-member-user",
        local.environment_management.account_ids["mlra-development"],
        local.environment_management.account_ids["mlra-test"],
        local.environment_management.account_ids["mlra-preproduction"],
        local.environment_management.account_ids["mlra-production"],
        local.environment_management.account_ids["apex-development"]
      ]

      # Tags
      tags_common = local.tags
    }

    apex = {
      push_principals = [
        "arn:aws:iam::${local.environment_management.account_ids["apex-development"]}:user/cicd-member-user",
        local.environment_management.account_ids["apex-development"]
      ]

      pull_principals = [
        "arn:aws:iam::${local.environment_management.account_ids["apex-development"]}:user/cicd-member-user",
        local.environment_management.account_ids["apex-development"],
        local.environment_management.account_ids["apex-test"],
        local.environment_management.account_ids["apex-preproduction"],
        local.environment_management.account_ids["apex-production"]
      ]

      # Tags
      tags_common = local.tags
    }

    instance-scheduler = {
      push_principals = [
        "arn:aws:iam::${local.environment_management.account_ids["core-shared-services-production"]}:role/github-actions"
      ]

      pull_principals = [
        local.environment_management.account_ids["core-shared-services-production"],
        local.environment_management.account_ids["testing-test"] # to enable terratest runs
      ]

      enable_retrieval_policy_for_lambdas = ["arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["core-shared-services-production"]}:function:*", "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["testing-test"]}:function:*"]

      # Tags
      tags_common = local.tags
    }

    delius-jitbit = {
      push_principals = [
        "arn:aws:iam::${local.environment_management.account_ids["delius-jitbit-development"]}:user/cicd-member-user",
        "arn:aws:iam::${local.environment_management.account_ids["delius-jitbit-test"]}:user/cicd-member-user",
        "arn:aws:iam::${local.environment_management.account_ids["delius-jitbit-preproduction"]}:user/cicd-member-user",
        "arn:aws:iam::${local.environment_management.account_ids["delius-jitbit-production"]}:user/cicd-member-user",
        "arn:aws:iam::${local.environment_management.account_ids["delius-jitbit-development"]}:role/modernisation-platform-oidc-cicd",
        "arn:aws:iam::${local.environment_management.account_ids["delius-jitbit-test"]}:role/modernisation-platform-oidc-cicd",
        "arn:aws:iam::${local.environment_management.account_ids["delius-jitbit-preproduction"]}:role/modernisation-platform-oidc-cicd",
        "arn:aws:iam::${local.environment_management.account_ids["delius-jitbit-production"]}:role/modernisation-platform-oidc-cicd"
      ]

      pull_principals = [
        local.environment_management.account_ids["delius-jitbit-development"],
        local.environment_management.account_ids["delius-jitbit-test"],
        local.environment_management.account_ids["delius-jitbit-preproduction"],
        local.environment_management.account_ids["delius-jitbit-production"]
      ]

      # Tags
      tags_common = local.tags
    }

    delius-core-weblogic = {
      push_principals = [
        "arn:aws:iam::${local.environment_management.account_ids["delius-core-development"]}:user/cicd-member-user"
      ]

      pull_principals = [
        local.environment_management.account_ids["delius-core-development"],
        "arn:aws:iam::${local.environment_management.account_ids["delius-core-development"]}:user/cicd-member-user"
      ]

      # Tags
      tags_common = local.tags
    }

    delius-core-testing-db = {
      push_principals = [
        "arn:aws:iam::${local.environment_management.account_ids["delius-core-development"]}:user/cicd-member-user"
      ]

      pull_principals = [
        local.environment_management.account_ids["delius-core-development"],
        "arn:aws:iam::${local.environment_management.account_ids["delius-core-development"]}:user/cicd-member-user"
      ]

      # Tags
      tags_common = local.tags
    }

    delius-core-openldap = {
      push_principals = [
        "arn:aws:iam::${local.environment_management.account_ids["delius-core-development"]}:user/cicd-member-user",
        "arn:aws:iam::${local.environment_management.account_ids["delius-core-development"]}:role/modernisation-platform-oidc-cicd",
        "arn:aws:iam::${local.environment_management.account_ids["delius-core-test"]}:role/modernisation-platform-oidc-cicd"
      ]

      pull_principals = [
        local.environment_management.account_ids["delius-core-development"],
        local.environment_management.account_ids["delius-core-test"],
        "arn:aws:iam::${local.environment_management.account_ids["delius-core-development"]}:user/cicd-member-user",
        "arn:aws:iam::${local.environment_management.account_ids["delius-core-development"]}:role/modernisation-platform-oidc-cicd",
        "arn:aws:iam::${local.environment_management.account_ids["delius-core-test"]}:role/modernisation-platform-oidc-cicd"
      ]

      # Tags
      tags_common = local.tags
    }

    data-platform-athena-load-lambda = {
      push_principals = [
        "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:user/cicd-member-user",
        "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/modernisation-platform-oidc-cicd",
        local.environment_management.account_ids["data-platform-development"],
        local.environment_management.account_ids["data-platform-test"],
        local.environment_management.account_ids["data-platform-preproduction"],
        local.environment_management.account_ids["data-platform-production"],
      ]

      pull_principals = [
        "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:user/cicd-member-user",
        local.environment_management.account_ids["data-platform-development"],
        local.environment_management.account_ids["data-platform-test"],
        local.environment_management.account_ids["data-platform-preproduction"],
        local.environment_management.account_ids["data-platform-production"],
      ]

      enable_retrieval_policy_for_lambdas = [
        "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-development"]}:function:data_product_athena_load*",
        "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-test"]}:function:data_product_athena_load*",
        "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-preproduction"]}:function:data_product_athena_load*",
        "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-production"]}:function:data_product_athena_load*"
      ]

      # Tags
      tags_common = local.tags
    }

    data-platform-get-glue-metadata-lambda = {
      push_principals = [
        "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:user/cicd-member-user",
        "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/modernisation-platform-oidc-cicd",
        local.environment_management.account_ids["data-platform-development"],
        local.environment_management.account_ids["data-platform-test"],
        local.environment_management.account_ids["data-platform-preproduction"],
        local.environment_management.account_ids["data-platform-production"],
      ]

      pull_principals = [
        "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:user/cicd-member-user",
        local.environment_management.account_ids["data-platform-development"],
        local.environment_management.account_ids["data-platform-test"],
        local.environment_management.account_ids["data-platform-preproduction"],
        local.environment_management.account_ids["data-platform-production"],
      ]

      enable_retrieval_policy_for_lambdas = [
        "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-development"]}:function:data_product_get_glue_metadata*",
        "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-test"]}:function:data_product_get_glue_metadata*",
        "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-preproduction"]}:function:data_product_get_glue_metadata*",
        "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-production"]}:function:data_product_get_glue_metadata*",
      ]

      # Tags
      tags_common = local.tags
    }

    data-platform-presigned-url-lambda = {
      push_principals = [
        "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:user/cicd-member-user",
        "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/modernisation-platform-oidc-cicd",
        local.environment_management.account_ids["data-platform-development"],
        local.environment_management.account_ids["data-platform-test"],
        local.environment_management.account_ids["data-platform-preproduction"],
        local.environment_management.account_ids["data-platform-production"],
      ]

      pull_principals = [
        "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:user/cicd-member-user",
        local.environment_management.account_ids["data-platform-development"],
        local.environment_management.account_ids["data-platform-test"],
        local.environment_management.account_ids["data-platform-preproduction"],
        local.environment_management.account_ids["data-platform-production"],
        local.environment_management.account_ids["analytical-platform-data-engineering-sandboxa"]
      ]

      enable_retrieval_policy_for_lambdas = [
        "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-development"]}:function:data_product_presigned_url*",
        "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-test"]}:function:data_product_presigned_url*",
        "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-preproduction"]}:function:data_product_presigned_url*",
        "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-production"]}:function:data_product_presigned_url*",
        "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["analytical-platform-data-engineering-sandboxa"]}:function:data_product_presigned_url*",
      ]

      # Tags
      tags_common = local.tags
    }

    data-platform-authorizer-lambda = {
      push_principals = [
        "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:user/cicd-member-user",
        "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/modernisation-platform-oidc-cicd",
        local.environment_management.account_ids["data-platform-development"],
        local.environment_management.account_ids["data-platform-test"],
        local.environment_management.account_ids["data-platform-preproduction"],
        local.environment_management.account_ids["data-platform-production"],
      ]

      pull_principals = [
        "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:user/cicd-member-user",
        local.environment_management.account_ids["data-platform-development"],
        local.environment_management.account_ids["data-platform-test"],
        local.environment_management.account_ids["data-platform-preproduction"],
        local.environment_management.account_ids["data-platform-production"],
        local.environment_management.account_ids["analytical-platform-data-engineering-sandboxa"],
      ]

      enable_retrieval_policy_for_lambdas = [
        "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-development"]}:function:data_product_authorizer*",
        "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-test"]}:function:data_product_authorizer*",
        "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-preproduction"]}:function:data_product_authorizer*",
        "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-production"]}:function:data_product_authorizer*",
        "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["analytical-platform-data-engineering-sandboxa"]}:function:data_product_authorizer*",
      ]

      # Tags
      tags_common = local.tags
    }

    data-platform-docs-lambda = {
      push_principals = [
        "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:user/cicd-member-user",
        "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/modernisation-platform-oidc-cicd",
        local.environment_management.account_ids["data-platform-development"],
        local.environment_management.account_ids["data-platform-test"],
        local.environment_management.account_ids["data-platform-preproduction"],
        local.environment_management.account_ids["data-platform-production"],
      ]

      pull_principals = [
        "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:user/cicd-member-user",
        local.environment_management.account_ids["data-platform-development"],
        local.environment_management.account_ids["data-platform-test"],
        local.environment_management.account_ids["data-platform-preproduction"],
        local.environment_management.account_ids["data-platform-production"],
      ]

      enable_retrieval_policy_for_lambdas = [
        "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-development"]}:function:data_product_docs*",
        "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-test"]}:function:data_product_docs*",
        "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-preproduction"]}:function:data_product_docs*",
        "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-production"]}:function:data_product_docs*",
      ]

      # Tags
      tags_common = local.tags
    }

    delius-core-ansible-aws = {
      push_principals = [
        "arn:aws:iam::${local.environment_management.account_ids["delius-core-development"]}:user/cicd-member-user"
      ]

      pull_principals = [
        local.environment_management.account_ids["delius-core-development"],
        "arn:aws:iam::${local.environment_management.account_ids["delius-core-development"]}:user/cicd-member-user"
      ]

      # Tags
      tags_common = local.tags
    }

    delius-core-ldap-automation = {
      push_principals = [
        "arn:aws:iam::${local.environment_management.account_ids["delius-core-development"]}:user/cicd-member-user"
      ]

      pull_principals = [
        local.environment_management.account_ids["delius-core-development"],
        "arn:aws:iam::${local.environment_management.account_ids["delius-core-development"]}:user/cicd-member-user"
      ]

      # Tags
      tags_common = local.tags
    }

    data-platform-python-base = {
      push_principals = [
        "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:user/cicd-member-user",
        "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/modernisation-platform-oidc-cicd",
        local.environment_management.account_ids["data-platform-development"],
        local.environment_management.account_ids["data-platform-test"],
        local.environment_management.account_ids["data-platform-preproduction"],
        local.environment_management.account_ids["data-platform-production"],
      ]

      pull_principals = [
        "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:user/cicd-member-user",
        "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/modernisation-platform-oidc-cicd",
        local.environment_management.account_ids["data-platform-development"],
        local.environment_management.account_ids["data-platform-test"],
        local.environment_management.account_ids["data-platform-preproduction"],
        local.environment_management.account_ids["data-platform-production"],
      ]

      # Tags
      tags_common = local.tags
    }

    data-platform-create-metadata-lambda = {
      push_principals = [
        "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:user/cicd-member-user",
        "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/modernisation-platform-oidc-cicd",
        local.environment_management.account_ids["data-platform-development"],
        local.environment_management.account_ids["data-platform-test"],
        local.environment_management.account_ids["data-platform-preproduction"],
        local.environment_management.account_ids["data-platform-production"],
      ]

      pull_principals = [
        "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:user/cicd-member-user",
        "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/modernisation-platform-oidc-cicd",
        local.environment_management.account_ids["data-platform-development"],
        local.environment_management.account_ids["data-platform-test"],
        local.environment_management.account_ids["data-platform-preproduction"],
        local.environment_management.account_ids["data-platform-production"],
      ]

      enable_retrieval_policy_for_lambdas = [
        "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-development"]}:function:data_product_create_metadata*",
        "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-test"]}:function:data_product_create_metadata*",
        "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-preproduction"]}:function:data_product_create_metadata*",
        "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-production"]}:function:data_product_create_metadata*",
      ]

      # Tags
      tags_common = local.tags
    }

    data-platform-resync-unprocessed-files-lambda = {
      push_principals = [
        "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:user/cicd-member-user",
        "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/modernisation-platform-oidc-cicd",
        local.environment_management.account_ids["data-platform-development"],
        local.environment_management.account_ids["data-platform-test"],
        local.environment_management.account_ids["data-platform-preproduction"],
        local.environment_management.account_ids["data-platform-production"],
      ]

      pull_principals = [
        "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:user/cicd-member-user",
        "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/modernisation-platform-oidc-cicd",
        local.environment_management.account_ids["data-platform-development"],
        local.environment_management.account_ids["data-platform-test"],
        local.environment_management.account_ids["data-platform-preproduction"],
        local.environment_management.account_ids["data-platform-production"],
      ]

      enable_retrieval_policy_for_lambdas = [
        "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-development"]}:function:resync_unprocessed_files*",
        "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-test"]}:function:resync_unprocessed_files*",
        "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-preproduction"]}:function:resync_unprocessed_files*",
        "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-production"]}:function:resync_unprocessed_files*",
      ]

      # Tags
      tags_common = local.tags
    }

    data-platform-reload-data-product-lambda = {
      push_principals = [
        "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:user/cicd-member-user",
        "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/modernisation-platform-oidc-cicd",
        local.environment_management.account_ids["data-platform-development"],
        local.environment_management.account_ids["data-platform-test"],
        local.environment_management.account_ids["data-platform-preproduction"],
        local.environment_management.account_ids["data-platform-production"],
      ]

      pull_principals = [
        "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:user/cicd-member-user",
        "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/modernisation-platform-oidc-cicd",
        local.environment_management.account_ids["data-platform-development"],
        local.environment_management.account_ids["data-platform-test"],
        local.environment_management.account_ids["data-platform-preproduction"],
        local.environment_management.account_ids["data-platform-production"],
      ]

      enable_retrieval_policy_for_lambdas = [
        "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-development"]}:function:reload_data_product*",
        "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-test"]}:function:reload_data_product*",
        "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-preproduction"]}:function:reload_data_product*",
        "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-production"]}:function:reload_data_product*",
      ]

      # Tags
      tags_common = local.tags
    }

    data-platform-landing-to-raw-lambda = {
      push_principals = [
        "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:user/cicd-member-user",
        "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/modernisation-platform-oidc-cicd",
        local.environment_management.account_ids["data-platform-development"],
        local.environment_management.account_ids["data-platform-test"],
        local.environment_management.account_ids["data-platform-preproduction"],
        local.environment_management.account_ids["data-platform-production"],
      ]

      pull_principals = [
        "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:user/cicd-member-user",
        "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/modernisation-platform-oidc-cicd",
        local.environment_management.account_ids["data-platform-development"],
        local.environment_management.account_ids["data-platform-test"],
        local.environment_management.account_ids["data-platform-preproduction"],
        local.environment_management.account_ids["data-platform-production"],
      ]

      enable_retrieval_policy_for_lambdas = [
        "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-development"]}:function:data_product_landing_to_raw*",
        "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-test"]}:function:data_product_landing_to_raw*",
        "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-preproduction"]}:function:data_product_landing_to_raw*",
        "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-production"]}:function:data_product_landing_to_raw*",
      ]

      # Tags
      tags_common = local.tags
    }

    data-platform-get-schema-lambda = {
      push_principals = [
        "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:user/cicd-member-user",
        "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/modernisation-platform-oidc-cicd",
        local.environment_management.account_ids["data-platform-development"],
        local.environment_management.account_ids["data-platform-test"],
        local.environment_management.account_ids["data-platform-preproduction"],
        local.environment_management.account_ids["data-platform-production"],
      ]

      pull_principals = [
        "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:user/cicd-member-user",
        "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/modernisation-platform-oidc-cicd",
        local.environment_management.account_ids["data-platform-development"],
        local.environment_management.account_ids["data-platform-test"],
        local.environment_management.account_ids["data-platform-preproduction"],
        local.environment_management.account_ids["data-platform-production"],
      ]

      enable_retrieval_policy_for_lambdas = [
        "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-development"]}:function:get_schema*",
        "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-test"]}:function:get_schema*",
        "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-preproduction"]}:function:get_schema*",
        "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-production"]}:function:get_schema*",
      ]

      # Tags
      tags_common = local.tags
    }

    data-platform-create-schema-lambda = {
      push_principals = [
        "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/modernisation-platform-oidc-cicd",
        local.environment_management.account_ids["data-platform-development"],
        local.environment_management.account_ids["data-platform-test"],
        local.environment_management.account_ids["data-platform-preproduction"],
        local.environment_management.account_ids["data-platform-production"],
      ]

      pull_principals = [
        "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/modernisation-platform-oidc-cicd",
        local.environment_management.account_ids["data-platform-development"],
        local.environment_management.account_ids["data-platform-test"],
        local.environment_management.account_ids["data-platform-preproduction"],
        local.environment_management.account_ids["data-platform-production"],
      ]

      enable_retrieval_policy_for_lambdas = [
        "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-development"]}:function:data_product_create_schema*",
        "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-test"]}:function:data_product_create_schema*",
        "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-preproduction"]}:function:data_product_create_schema*",
        "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-production"]}:function:data_product_create_schema*",
      ]

      # Tags
      tags_common = local.tags
    }

    data-platform-update-metadata-lambda = {
      push_principals = [
        "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/modernisation-platform-oidc-cicd",
        local.environment_management.account_ids["data-platform-development"],
        local.environment_management.account_ids["data-platform-test"],
        local.environment_management.account_ids["data-platform-preproduction"],
        local.environment_management.account_ids["data-platform-production"],
      ]

      pull_principals = [
        "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/modernisation-platform-oidc-cicd",
        local.environment_management.account_ids["data-platform-development"],
        local.environment_management.account_ids["data-platform-test"],
        local.environment_management.account_ids["data-platform-preproduction"],
        local.environment_management.account_ids["data-platform-production"],
      ]

      enable_retrieval_policy_for_lambdas = [
        "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-development"]}:function:data_product_update_metadata*",
        "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-test"]}:function:data_product_update_metadata*",
        "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-preproduction"]}:function:data_product_update_metadata*",
        "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-production"]}:function:data_product_update_metadata*",
      ]

      # Tags
      tags_common = local.tags
    }

    data-platform-update-schema-lambda = {
      push_principals = [
        "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/modernisation-platform-oidc-cicd",
        local.environment_management.account_ids["data-platform-development"],
        local.environment_management.account_ids["data-platform-test"],
        local.environment_management.account_ids["data-platform-preproduction"],
        local.environment_management.account_ids["data-platform-production"],
      ]

      pull_principals = [
        "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/modernisation-platform-oidc-cicd",
        local.environment_management.account_ids["data-platform-development"],
        local.environment_management.account_ids["data-platform-test"],
        local.environment_management.account_ids["data-platform-preproduction"],
        local.environment_management.account_ids["data-platform-production"],
      ]

      enable_retrieval_policy_for_lambdas = [
        "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-development"]}:function:data_product_update_schema*",
        "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-test"]}:function:data_product_update_schema*",
        "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-preproduction"]}:function:data_product_update_schema*",
        "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-production"]}:function:data_product_update_schema*",
      ]

      # Tags
      tags_common = local.tags
    }

    data-platform-preview-data-lambda = {
      push_principals = [
        "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/modernisation-platform-oidc-cicd",
        local.environment_management.account_ids["data-platform-development"],
        local.environment_management.account_ids["data-platform-test"],
        local.environment_management.account_ids["data-platform-preproduction"],
        local.environment_management.account_ids["data-platform-production"],
      ]

      pull_principals = [
        "arn:aws:iam::${local.environment_management.account_ids["data-platform-development"]}:role/modernisation-platform-oidc-cicd",
        local.environment_management.account_ids["data-platform-development"],
        local.environment_management.account_ids["data-platform-test"],
        local.environment_management.account_ids["data-platform-preproduction"],
        local.environment_management.account_ids["data-platform-production"],
      ]

      enable_retrieval_policy_for_lambdas = [
        "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-development"]}:function:data_product_preview_data*",
        "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-test"]}:function:data_product_preview_data*",
        "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-preproduction"]}:function:data_product_preview_data*",
        "arn:aws:lambda:eu-west-2:${local.environment_management.account_ids["data-platform-production"]}:function:data_product_preview_data*",
      ]

      # Tags
      tags_common = local.tags
    }

  }
}