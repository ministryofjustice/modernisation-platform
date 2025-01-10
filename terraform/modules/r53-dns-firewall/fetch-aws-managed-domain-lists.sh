#!/bin/bash

aws route53resolver list-firewall-domain-lists | jq -r '
{
  "AWSManagedDomainsAggregateThreatList": (.FirewallDomainLists[] | select(.Name == "AWSManagedDomainsAggregateThreatList") | .Id),
  "AWSManagedDomainsMalwareDomainList": (.FirewallDomainLists[] | select(.Name == "AWSManagedDomainsMalwareDomainList") | .Id),
  "AWSManagedDomainsBotnetCommandandControl": (.FirewallDomainLists[] | select(.Name == "AWSManagedDomainsBotnetCommandandControl") | .Id),
  "AWSManagedDomainsAmazonGuardDutyThreatList": (.FirewallDomainLists[] | select(.Name == "AWSManagedDomainsAmazonGuardDutyThreatList") | .Id)
}'