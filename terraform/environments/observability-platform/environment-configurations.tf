locals {
  environment_configuration = local.environment_configurations[local.environment]
  environment_configurations = {
    development = {
      data_platform_apps_tools_account_id = local.environment_management.account_ids["data-platform-apps-and-tools-development"]
    }
    test = {
      data_platform_apps_tools_account_id = local.environment_management.account_ids["data-platform-apps-and-tools-development"]
    }
    preproduction = {
      data_platform_apps_tools_account_id = local.environment_management.account_ids["data-platform-apps-and-tools-development"]
    }
    production = {
      data_platform_apps_tools_account_id = local.environment_management.account_ids["data-platform-apps-and-tools-production"]
    }
  }
}
