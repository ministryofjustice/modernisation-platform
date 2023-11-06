locals {
  environment_configuration = local.environment_configurations[local.environment]
  environment_configurations = {
    development = {
      source_accounts = [
        local.environment_management.account_ids["data-platform-apps-and-tools-development"],
        local.environment_management.account_ids["data-platform-development"],
        local.environment_management.account_ids["data-platform-test"],
        local.environment_management.account_ids["data-platform-preproduction"]
      ]
      data_platform_apps_tools_account_id = local.environment_management.account_ids["data-platform-apps-and-tools-development"]
    }
    test = {
      data_platform_apps_tools_account_id = local.environment_management.account_ids["data-platform-apps-and-tools-development"]
    }
    preproduction = {
      data_platform_apps_tools_account_id = local.environment_management.account_ids["data-platform-apps-and-tools-development"]
    }
    production = {
      source_accounts = [
        local.environment_management.account_ids["data-platform-production"],
        local.environment_management.account_ids["data-platform-apps-and-tools-production"]
      ]
      data_platform_apps_tools_account_id = local.environment_management.account_ids["data-platform-apps-and-tools-production"]
    }
  }
}

