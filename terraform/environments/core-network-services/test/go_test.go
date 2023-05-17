package test

import (
    "encoding/json"
	"testing"
	"regexp"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestTransitGateway(t *testing.T) {
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../",
	})

	terraform.RunTerraformCommand(t, terraformOptions, "refresh")
	terraform.Plan(t, terraformOptions)

	//Test private route tables
	var privateRouteTableData = []string{
		"private-eu-west-2a",
		"private-eu-west-2b",
		"private-eu-west-2c",
		"data-eu-west-2a",
		"data-eu-west-2b",
		"data-eu-west-2c",
		"transit-gateway-eu-west-2a",
		"transit-gateway-eu-west-2b",
		"transit-gateway-eu-west-2c",
	}
	//Test for non_live private route tables
	for _, element := range privateRouteTableData {
		output := terraform.Output(t, terraformOptions, "non_live_data_private_route_tables")
		assert.Contains(t, output, element)
	}
	//Test for live private route tables
	for _, element := range privateRouteTableData {
		output := terraform.Output(t, terraformOptions, "live_data_private_route_tables")
		assert.Contains(t, output, element)
	}

	//Test public igw cidr
	output7 := terraform.Output(t, terraformOptions, "public_route_tables")
	assert.Equal(t, output7, "map[live_data:live_data-public non_live_data:non_live_data-public]")

	//Test public igw cidr
	output1 := terraform.Output(t, terraformOptions, "public_igw_route")
	assert.Equal(t, output1, "map[live_data:0.0.0.0/0 non_live_data:0.0.0.0/0]")

	//Test transit-gateway will not be affected
	output2 := terraform.Output(t, terraformOptions, "transit_gateway")
	assert.Equal(t, output2, "64589")

	//Test tgw-subnet count. There should be 3
	output3 := terraform.Output(t, terraformOptions, "tgw_subnet_ids")
	assert.Equal(t, output3, "3")

	//Test non-tgw-subnets count. There should be 9
	output4 := terraform.Output(t, terraformOptions, "non_tgw_subnet_ids")
	assert.Equal(t, output4, "9")

	//Check the correct CIDR address have been added
	output5 := terraform.Output(t, terraformOptions, "vpc_cidrs")
	assert.Equal(t, output5, "map[live_data:10.20.0.0/19 non_live_data:10.20.32.0/19]")

	//Check the transit gateway ram share is created
	output6 := terraform.Output(t, terraformOptions, "transit_gateway_ram_share")
	assert.Equal(t, output6, "transit-gateway")

}

func TestInspectionVPCs(t *testing.T) {
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../",
	})

	terraform.RunTerraformCommand(t, terraformOptions, "refresh")
	terraform.Plan(t, terraformOptions)

	// Retrieve the VPC output as a map
    inspectionVPCs := terraform.OutputMap(t, terraformOptions, "inspection_vpc_ids")

	// Define a regular expression pattern to match the VPC IDs
    vpcIDPattern := regexp.MustCompile(`^vpc-[0-9a-f]{17}$`)

	// Assert that the vpc_id values in the map match the regular expression pattern
	assert.Regexp(t, vpcIDPattern, inspectionVPCs["non_live_data"], "non_live_data vpc_id does not match the expected pattern")
	assert.Regexp(t, vpcIDPattern, inspectionVPCs["live_data"], "live_data vpc_id does not match the expected pattern")

	// Retrieve the subnet outputs
	inspectionTgwSubnets := terraform.OutputMap(t, terraformOptions, "inspection_tgw_subnets")
	inspectionInspectionSubnets := terraform.OutputMap(t, terraformOptions, "inspection_inspection_subnets")
	inspectionPublicSubnets := terraform.OutputMap(t, terraformOptions, "inspection_public_subnets")

    // Assert that non_live_data has all of its subnets
	assert.Equal(t, inspectionTgwSubnets["non_live_data"], "3")
	assert.Equal(t, inspectionInspectionSubnets["non_live_data"], "3")
	assert.Equal(t, inspectionPublicSubnets["non_live_data"], "3")

    // Assert that live_data has all of its subnets
	assert.Equal(t, inspectionTgwSubnets["live_data"], "3")
	assert.Equal(t, inspectionInspectionSubnets["live_data"], "3")
	assert.Equal(t, inspectionPublicSubnets["live_data"], "3")

	// Retrieve firewall ARNs as a map
	inspectionFirewalls := terraform.OutputMap(t, terraformOptions, "firewall_arn")
	// Define a regular expression pattern to match the VPC IDs
    firewallARNPattern := regexp.MustCompile(`^arn:aws:network-firewall:eu-west-2:[0-9]{12}:firewall/(live-data|non-live-data)-inline-inspection$`)
    // Assert that the firewall_arn values in the map match the regular expression pattern
	assert.Regexp(t, firewallARNPattern, inspectionFirewalls["non_live_data"], "non_live_data firewall_arn does not match the expected pattern")
	assert.Regexp(t, firewallARNPattern, inspectionFirewalls["live_data"], "live_data firewall_arn does not match the expected pattern")

	// Retrieve Internet Gateway IDs
	inspectionIGWs := terraform.OutputMap(t, terraformOptions, "inspection_igw_id")
	// Define a regular expression pattern to match the VPC IDs
    igwIDPattern := regexp.MustCompile(`^igw-[0-9a-f]{17}$`)
	// Assert that both live_data and non_live_data have an IGW matching the regext
	assert.Regexp(t, igwIDPattern, inspectionIGWs["non_live_data"], "non_live_data igw_id does not match the expected pattern")
	assert.Regexp(t, igwIDPattern, inspectionIGWs["live_data"], "live_data igw_id does not match the expected pattern")

	// Retrieve a map of NAT Gateway outputs
	inspectionNATGWs := terraform.OutputMap(t, terraformOptions, "inspection_natgw_ids")

    // Assert that each VPC has all of its NAT Gateways
	assert.Equal(t, inspectionNATGWs["non_live_data"], "3")
	assert.Equal(t, inspectionNATGWs["non_live_data"], "3")

	// Run `terraform output` to get the value of the output variable as a string
	terraformOutput := terraform.OutputJson(t, terraformOptions, "inspection_default_routes")

	// Parse the string value as JSON to obtain the map structure
	var inspectionDefaultRoutes map[string]interface{}
	err := json.Unmarshal([]byte(terraformOutput), &inspectionDefaultRoutes)
	if err != nil {
		t.Fatalf("Failed to parse inspection_default_routes output as JSON: %s", err)
	}

	// Check the number of keys in `inspection_default_routes`
	liveDataRoutes, _ := inspectionDefaultRoutes["live_data"].(map[string]interface{})
	nonLiveDataRoutes, _ := inspectionDefaultRoutes["non_live_data"].(map[string]interface{})

	assert.Len(t, liveDataRoutes, 9)
	assert.Len(t, nonLiveDataRoutes, 9)

	// Check the values of the keys in `inspection_default_routes`
	for _, value := range liveDataRoutes {
		assert.Equal(t, "0.0.0.0/0", value)
	}
	for _, value := range nonLiveDataRoutes {
		assert.Equal(t, "0.0.0.0/0", value)
	}
}