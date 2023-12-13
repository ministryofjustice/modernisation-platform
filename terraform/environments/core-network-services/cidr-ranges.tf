locals {
  mp_core_cidr_ranges = {
    mp-core                     = "10.20.0.0/16"
    mp-development-test         = "10.26.0.0/16"
    mp-preproduction-production = "10.27.0.0/16"
  }

  # This will take the vpc CIDR ranges for each business/env general subnet set, from the environments-networks files
  # e.g. `hmpps-development = "10.26.24.0/21"
  platform_general_set_cidr_ranges = {
    for key, value in local.core-vpcs : key => value.cidr.subnet_sets.general.cidr
  }

  other_cidr_ranges = {
    analytical-platform-airflow-dev  = "10.200.0.0/16"
    analytical-platform-airflow-prod = "10.201.0.0/16"
    atos_arkc_ras                    = "10.175.0.0/16" # for DOM1 devices connected to Cisco RAS VPN
    atos_arkf_ras                    = "10.176.0.0/16" # for DOM1 devices connected to Cisco RAS VPN
    cloud-platform                   = "172.20.0.0/16"
    global-protect                   = "10.184.0.0/16"
    i2n                              = "10.110.0.0/16"
    moj-core-azure-1                 = "10.50.25.0/27"
    moj-core-azure-2                 = "10.50.26.0/24"
    parole-board                     = "10.50.0.0/16"
    psn                              = "51.0.0.0/8"
    psn-ppud                         = "51.247.2.115/32"
    vodafone_wan_nicts_aggregate     = "10.80.0.0/12" # for devices connected to Prison Networks

    # hmpps azure cidr ranges
    noms-live-vnet                 = "10.40.0.0/18"
    noms-live-dr-vnet              = "10.40.64.0/18"
    noms-mgmt-live-vnet            = "10.40.128.0/20"
    noms-mgmt-live-dr-vnet         = "10.40.144.0/20"
    noms-transit-live-vnet         = "10.40.160.0/20"
    noms-transit-live-dr-vnet      = "10.40.176.0/20"
    noms-test-vnet                 = "10.101.0.0/16"
    noms-mgmt-vnet                 = "10.102.0.0/16"
    noms-test-dr-vnet              = "10.111.0.0/16"
    noms-mgmt-dr-vnet              = "10.112.0.0/16"
    aks-studio-hosting-live-1-vnet = "10.244.0.0/20"
    aks-studio-hosting-dev-1-vnet  = "10.247.0.0/20"
    aks-studio-hosting-ops-1-vnet  = "10.247.32.0/20"
    nomisapi-t2-root-vnet          = "10.47.0.192/26"
    nomisapi-t3-root-vnet          = "10.47.0.0/26"
    nomisapi-preprod-root-vnet     = "10.47.0.64/26"
    nomisapi-prod-root-vnet        = "10.47.0.128/26"
    moj-smtp-relay1              = "10.180.104.100/32"
    moj-smtp-relay2              = "10.180.105.100/32"

    # hmpps aws cidr ranges
    delius-eng-dev  = "10.161.98.0/25"
    delius-eng-prod = "10.160.98.0/25"
    delius-core-dev = "10.161.20.0/22"
    delius-mis-dev  = "10.162.32.0/20"
    delius-test     = "10.162.0.0/20"
    delius-stage    = "10.160.32.0/20"
    delius-pre-prod = "10.160.0.0/20"
    delius-training = "10.162.96.0/20"
    delius-prod     = "10.160.16.0/20"

    # laa landing zone cidr ranges
    laa-lz-development             = "10.202.0.0/20"
    laa-lz-test                    = "10.203.0.0/20"
    laa-lz-uat                     = "10.206.0.0/20"
    laa-lz-staging                 = "10.204.0.0/20"
    laa-lz-production              = "10.205.0.0/20"
    laa-lz-shared-services-nonprod = "10.200.0.0/20"
    laa-lz-shared-services-prod    = "10.200.16.0/20"
    laa-appstream-vpc              = "10.200.32.0/19"
    laa-appstream-vpc_additional   = "10.200.68.0/22"

    hmpps-preproduction-general-private-subnets = "10.27.0.0/22"
    hmpps-production-general-private-subnets    = "10.27.10.0/22"
  }

  all_cidr_ranges = merge(
    local.mp_core_cidr_ranges,
    local.platform_general_set_cidr_ranges,
    local.other_cidr_ranges
  )
}
