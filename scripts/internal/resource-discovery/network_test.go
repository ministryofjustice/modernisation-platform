package main

import "testing"

func TestIsNetworkResourceType(t *testing.T) {
	tests := map[string]bool{
		"AWS::EC2::VPC":                             true,
		"AWS::EC2::Subnet":                          true,
		"AWS::EC2::SecurityGroup":                   true,
		"AWS::ElasticLoadBalancingV2::LoadBalancer": true,
		"AWS::NetworkFirewall::Firewall":            true,
		"AWS::OpenSearchServerless::VpcEndpoint":    true,
		"AWS::RDS::DBSubnetGroup":                   true,
		"AWS::Route53Resolver::ResolverEndpoint":    true,
		"AWS::EC2::Instance":                        false,
		"AWS::EC2::Volume":                          false,
		"AWS::Lambda::Function":                     false,
		"AWS::RDS::DBInstance":                      false,
		"AWS::S3::Bucket":                           false,
	}

	for resourceType, want := range tests {
		t.Run(resourceType, func(t *testing.T) {
			if got := isNetworkResourceType(resourceType); got != want {
				t.Fatalf("isNetworkResourceType(%q) = %t, want %t", resourceType, got, want)
			}
		})
	}
}
