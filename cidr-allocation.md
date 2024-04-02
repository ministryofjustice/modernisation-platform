# CIDR allocation register

| CIDR       | mask | allocated to                             |                            |
| :--------- | :--- | :--------------------------------------- | -------------------------- |
| 10.20.0.0  | /16  | used for vpcs in core accounts           |                            |
| 10.26.0.0  | /16  | shared-vpcs development and test         |                            |
| 10.27.0.0  | /16  | shared-vpcs preproduction and production |                            |
| 10.239.0.0 | /16  | shared-vpcs sandbox (NOT ROUTEABLE)      | Use for local testing only |
|            |      |

# Core Accounts CIDRs

| CIDR        | mask | allocated to                        |
| :---------- | :--- | :---------------------------------- |
| 10.20.0.0   | /19  | core-network-services live_data     |
| 10.20.32.0  | /19  | core-network-services non_live_data |
| 10.20.64.0  | /19  | core-shared-services live_data      |
| 10.20.96.0  | /19  | core-shared-services non_live_data  |
| 10.20.128.0 | /19  | core-logging live_data              |
| 10.20.160.0 | /19  | core-logging non_live_data          |
| 10.20.192.0 | /19  | core-security live_data             |
| 10.20.224.0 | /19  | core-security non_live_data         |
|             |      |

### development and test /21s for member subnet-sets

| CIDR        | mask | allocated to                           |
| :---------- | :--- | :------------------------------------- |
| 10.26.0.0   | /21  | platforms test - general               |
| 10.26.8.0   | /21  | hmpps test - general                   |
| 10.26.16.0  | /21  | platforms development - general        |
| 10.26.24.0  | /21  | hmpps development - general            |
| 10.26.32.0  | /21  | cica development - general             |
| 10.26.40.0  | /21  | hmcts development - general            |
| 10.26.48.0  | /21  | hq development - general               |
| 10.26.56.0  | /21  | laa development - general              |
| 10.26.64.0  | /21  | opg test - general                     |
| 10.26.72.0  | /21  | opg development - general              |
| 10.26.80.0  | /21  | cjse-development - general             |
| 10.26.88.0  | /21  | cjse-test - general                    |
| 10.26.96.0  | /21  | laa-test - general                     |
| 10.26.104.0 | /21  | hmcts-test - general                   |
| 10.26.112.0 | /21  | cica-test - general                    |
| 10.26.120.0 | /21  | hq-test - general                      |
| 10.26.128.0 | /21  | data-platform development - networking |
| 10.26.136.0 | /21  | -                                      |
| 10.26.144.0 | /21  | -                                      |
| 10.26.152.0 | /21  | -                                      |
| 10.26.160.0 | /21  | -                                      |
| 10.26.168.0 | /21  | -                                      |
| 10.26.176.0 | /21  | -                                      |
| 10.26.184.0 | /21  | -                                      |
| 10.26.192.0 | /21  | -                                      |
| 10.26.200.0 | /21  | -                                      |
| 10.26.208.0 | /21  | -                                      |
| 10.26.216.0 | /21  | -                                      |
| 10.26.224.0 | /21  | -                                      |
| 10.26.232.0 | /21  | -                                      |
| 10.26.240.0 | /21  | -                                      |
| 10.26.248.0 | /21  | -                                      |
|             |      |

### preproduction and production /21s for member subnet-sets

| CIDR        | mask | allocated to                          |
| :---------- | :--- |:--------------------------------------|
| 10.27.0.0   | /21  | hmpps preproduction - general         |
| 10.27.8.0   | /21  | hmpps production - general            |
| 10.27.16.0  | /21  | hmcts production - general            |
| 10.27.24.0  | /21  | hmcts preproduction - general         |
| 10.27.32.0  | /21  | hq production - general               |
| 10.27.40.0  | /21  | hq preproduction - general            |
| 10.27.48.0  | /21  | opg production - general              |
| 10.27.56.0  | /21  | opg preproduction - general           |
| 10.27.64.0  | /21  | laa production - general              |
| 10.27.72.0  | /21  | laa preproduction - general           |
| 10.27.80.0  | /21  | cica production - general             |
| 10.27.88.0  | /21  | cica preproduction - general          |
| 10.27.96.0  | /21  | platforms production - general        |
| 10.27.104.0 | /21  | platforms preproduction - general     |
| 10.27.112.0 | /21  | cjse production - general             |
| 10.27.120.0 | /21  | cjse preproduction - general          |
| 10.27.128.0 | /21  | data-platform production - networking |
| 10.27.136.0 | /21  | core-shared-services live_data        |
| 10.27.144.0 | /21  | -                                     |
| 10.27.152.0 | /21  | -                                     |
| 10.27.160.0 | /21  | -                                     |
| 10.27.168.0 | /21  | -                                     |
| 10.27.176.0 | /21  | -                                     |
| 10.27.184.0 | /21  | -                                     |
| 10.27.192.0 | /21  | -                                     |
| 10.27.200.0 | /21  | -                                     |
| 10.27.208.0 | /21  | -                                     |
| 10.27.216.0 | /21  | -                                     |
| 10.27.224.0 | /21  | -                                     |
| 10.27.232.0 | /21  | -                                     |
| 10.27.240.0 | /21  | -                                     |
| 10.27.248.0 | /21  | -                                     |
|             |      |

### sandbox /21s for member subnet-sets

| CIDR        | mask | allocated to              |
|:------------| :--- | :------------------------ |
| 10.231.0.0  | /21  | LAB ONLY garden - general |
| 10.231.8.0  | /21  | LAB ONLY house - general  |
| 10.231.16.0 | /21  | -                         |
| 10.231.24.0 | /21  | -                         |
| 10.231.32.0 | /21  | -                         |
|             |      |
