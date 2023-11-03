locals {
  environment_configuration = local.environment_configurations[local.environment]
  environment_configurations = {
    development = {
      data_platform_apps_tools_account_id = local.environment_management.account_ids["data-platform-apps-and-tools-development"]
      data_platform_account_id            = local.environment_management.account_ids["data-platform-development"],
    }
    test = {
      data_platform_apps_tools_account_id = local.environment_management.account_ids["data-platform-apps-and-tools-development"]
      data_platform_account_id            = local.environment_management.account_ids["data-platform-test"],
    }
    preproduction = {
      data_platform_apps_tools_account_id = local.environment_management.account_ids["data-platform-apps-and-tools-development"]
      data_platform_account_id            = local.environment_management.account_ids["data-platform-preproduction"]
    }
    production = {
      data_platform_apps_tools_account_id = local.environment_management.account_ids["data-platform-apps-and-tools-production"]
      data_platform_account_id            = local.environment_management.account_ids["data-platform-production"]
    }
  }
}
