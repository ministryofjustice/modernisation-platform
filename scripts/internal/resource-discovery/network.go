package main

import "strings"

var networkResourceTypePrefixes = []string{
	"AWS::AppMesh::",
	"AWS::CloudFront::",
	"AWS::DirectConnect::",
	"AWS::ElasticLoadBalancing::",
	"AWS::ElasticLoadBalancingV2::",
	"AWS::GlobalAccelerator::",
	"AWS::NetworkFirewall::",
	"AWS::NetworkManager::",
	"AWS::Route53::",
	"AWS::Route53Profiles::",
	"AWS::Route53RecoveryControl::",
	"AWS::Route53RecoveryReadiness::",
	"AWS::Route53Resolver::",
	"AWS::ServiceDiscovery::",
	"AWS::VpcLattice::",
}

var networkResourceTypes = map[string]struct{}{
	"AWS::ApiGateway::VpcLink":                     {},
	"AWS::ApiGatewayV2::VpcLink":                   {},
	"AWS::AppRunner::VpcConnector":                 {},
	"AWS::DMS::ReplicationSubnetGroup":             {},
	"AWS::EC2::CarrierGateway":                     {},
	"AWS::EC2::ClientVpnEndpoint":                  {},
	"AWS::EC2::CustomerGateway":                    {},
	"AWS::EC2::DHCPOptions":                        {},
	"AWS::EC2::EgressOnlyInternetGateway":          {},
	"AWS::EC2::EIP":                                {},
	"AWS::EC2::EIPAssociation":                     {},
	"AWS::EC2::FlowLog":                            {},
	"AWS::EC2::InstanceConnectEndpoint":            {},
	"AWS::EC2::InternetGateway":                    {},
	"AWS::EC2::IPAM":                               {},
	"AWS::EC2::IPAMPool":                           {},
	"AWS::EC2::IPAMPoolCidr":                       {},
	"AWS::EC2::IPAMResourceDiscovery":              {},
	"AWS::EC2::IPAMResourceDiscoveryAssociation":   {},
	"AWS::EC2::IPAMScope":                          {},
	"AWS::EC2::NatGateway":                         {},
	"AWS::EC2::NetworkAcl":                         {},
	"AWS::EC2::NetworkInsightsAccessScope":         {},
	"AWS::EC2::NetworkInsightsAccessScopeAnalysis": {},
	"AWS::EC2::NetworkInsightsAnalysis":            {},
	"AWS::EC2::NetworkInsightsPath":                {},
	"AWS::EC2::NetworkInterface":                   {},
	"AWS::EC2::PrefixList":                         {},
	"AWS::EC2::RouteTable":                         {},
	"AWS::EC2::SecurityGroup":                      {},
	"AWS::EC2::SecurityGroupVpcAssociation":        {},
	"AWS::EC2::Subnet":                             {},
	"AWS::EC2::SubnetCidrBlock":                    {},
	"AWS::EC2::SubnetNetworkAclAssociation":        {},
	"AWS::EC2::SubnetRouteTableAssociation":        {},
	"AWS::EC2::TrafficMirrorFilter":                {},
	"AWS::EC2::TrafficMirrorSession":               {},
	"AWS::EC2::TrafficMirrorTarget":                {},
	"AWS::EC2::TransitGateway":                     {},
	"AWS::EC2::TransitGatewayAttachment":           {},
	"AWS::EC2::TransitGatewayConnect":              {},
	"AWS::EC2::TransitGatewayMulticastDomain":      {},
	"AWS::EC2::TransitGatewayPeering":              {},
	"AWS::EC2::TransitGatewayRouteTable":           {},
	"AWS::EC2::VerifiedAccessInstance":             {},
	"AWS::EC2::VPC":                                {},
	"AWS::EC2::VPCBlockPublicAccessExclusion":      {},
	"AWS::EC2::VPCBlockPublicAccessOptions":        {},
	"AWS::EC2::VPCEncryptionControl":               {},
	"AWS::EC2::VPCEndpoint":                        {},
	"AWS::EC2::VPCEndpointConnectionNotification":  {},
	"AWS::EC2::VPCEndpointService":                 {},
	"AWS::EC2::VPCGatewayAttachment":               {},
	"AWS::EC2::VPCPeeringConnection":               {},
	"AWS::EC2::VPNConnection":                      {},
	"AWS::EC2::VPNConnectionRoute":                 {},
	"AWS::EC2::VPNGateway":                         {},
	"AWS::ElastiCache::SubnetGroup":                {},
	"AWS::MediaConnect::FlowVpcInterface":          {},
	"AWS::MemoryDB::SubnetGroup":                   {},
	"AWS::MSK::VpcConnection":                      {},
	"AWS::OpenSearchServerless::VpcEndpoint":       {},
	"AWS::RDS::DBSecurityGroup":                    {},
	"AWS::RDS::DBSubnetGroup":                      {},
	"AWS::Redshift::ClusterSecurityGroup":          {},
	"AWS::Redshift::ClusterSubnetGroup":            {},
	"AWS::Redshift::EndpointAccess":                {},
	"AWS::Redshift::EndpointAuthorization":         {},
}

func isNetworkResourceType(resourceType string) bool {
	if _, found := networkResourceTypes[resourceType]; found {
		return true
	}

	for _, prefix := range networkResourceTypePrefixes {
		if strings.HasPrefix(resourceType, prefix) {
			return true
		}
	}

	return false
}
