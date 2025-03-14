locals {
  mp_core_cidr_ranges = {
    mp-core                            = "10.20.0.0/16"
    mp-core-shared-services-additional = "10.27.136.0/21"
    mp-development-test                = "10.26.0.0/16"
    mp-preproduction-production        = "10.27.0.0/16"
    mp-sandbox                         = "10.231.0.0/20"
    mp-sandbox-garden                  = "10.231.0.0/21"
    mp-sandbox-house                   = "10.231.8.0/21"
  }

  # This will take the vpc CIDR ranges for each business/env general subnet set, from the environments-networks files
  # e.g. `hmpps-development = "10.26.24.0/21"
  platform_general_set_cidr_ranges = {
    for key, value in local.core-vpcs : key => value.cidr.subnet_sets.general.cidr
  }

  other_cidr_ranges = {
    analytical-platform-airflow-dev  = "10.200.0.0/16"
    analytical-platform-airflow-prod = "10.201.0.0/16"
    data-engineering-dev             = "172.24.0.0/16"
    data-engineering-prod            = "172.25.0.0/16"
    data-engineering-stage           = "172.26.0.0/16"
    atos_arkc_ras                    = "10.175.0.0/16" # for DOM1 devices connected to Cisco RAS VPN
    atos_arkf_ras                    = "10.176.0.0/16" # for DOM1 devices connected to Cisco RAS VPN
    cloud-platform                   = "172.20.0.0/16"
    dom1-domain-controllers          = "10.172.68.146/29"
    global-protect                   = "10.184.0.0/14"
    i2n                              = "10.110.0.0/16"
    moj-core-azure-1                 = "10.50.25.0/27"
    moj-core-azure-2                 = "10.50.26.0/24"
    mojo-azure-landing-zone          = "10.192.0.0/16"
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
    moj-smtp-relay1                = "10.180.104.100/32"
    moj-smtp-relay2                = "10.180.105.100/32"

    # hmpps aws cidr ranges
    delius-eng-dev                    = "10.161.98.0/25"
    delius-eng-prod                   = "10.160.98.0/25"
    delius-mis-dev                    = "10.162.32.0/20"
    delius-mis-dev-private-eu-west-2a = "10.162.32.0/22"
    delius-mis-dev-private-eu-west-2b = "10.162.36.0/22"
    delius-mis-dev-private-eu-west-2c = "10.162.40.0/22"
    delius-test                       = "10.162.0.0/20"
    delius-stage                      = "10.160.32.0/20"
    delius-pre-prod                   = "10.160.0.0/20"
    delius-training                   = "10.162.96.0/20"
    delius-prod                       = "10.160.16.0/20"

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

    # cica cidr ranges
    cica-aws-ss-a         = "10.10.10.0/24"
    cica-aws-ss-b         = "10.10.110.0/24"
    cica-aws-dev-a        = "10.11.10.0/24"
    cica-aws-dev-b        = "10.11.110.0/24"
    cica-aws-dev-data-a   = "10.11.20.0/24"
    cica-aws-dev-data-b   = "10.11.120.0/24"
    cica-aws-uat-a        = "10.12.10.0/24"
    cica-aws-uat-b        = "10.12.110.0/24"
    cica-aws-uat-data-a   = "10.12.20.0/24"
    cica-aws-uat-data-b   = "10.12.120.0/24"
    cica-onprem-uat       = "192.168.4.0/24"
    cica-onprem-prod      = "10.2.30.0/24"
    cica-end-user-devices = "10.9.14.0/23"
    cica-ras-nat          = "10.7.14.224/28"



    mojo-end-user-devices = "10.0.0.0/8"
    dom1-dcs              = "10.0.0.0/8"
    ad-hmpp-dc-a          = "10.27.136.5/32" # see https://github.com/ministryofjustice/modernisation-platform/issues/5970
    ad-hmpp-dc-b          = "10.27.137.5/32" # and https://dsdmoj.atlassian.net/wiki/x/3oCKGAE
    ad-hmpp-rdlic         = "10.27.138.6/32" # ditto
    ad-azure-dc-a         = "10.20.104.5/32" # ditto
    ad-azure-dc-b         = "10.20.106.5/32" # ditto
    ad-azure-rdlic        = "10.20.108.6/32" # ditto
  }

  all_cidr_ranges = merge(
    local.mp_core_cidr_ranges,
    local.platform_general_set_cidr_ranges,
    local.other_cidr_ranges
  )
}
