package test

import (
	"testing"

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

	//Test transit-gateway will not be affected
	output2 := terraform.Output(t, terraformOptions, "transit_gateway")
	assert.Equal(t, output2, "64589")

	//Test tgw-subnet count. There should be 3
	output3 := terraform.Output(t, terraformOptions, "tgw_subnet_ids")
	assert.Equal(t, output3, "3")

	//Test non-tgw-subnets count. There should be 12
	output4 := terraform.Output(t, terraformOptions, "non_tgw_subnet_ids")
	assert.Equal(t, output4, "12")

	//Check the correct CIDR address have been added
	output5 := terraform.Output(t, terraformOptions, "vpc_cidrs")
	assert.Equal(t, output5, "map[live_data:10.20.0.0/19 non_live_data:10.20.32.0/19]")

	//Check the transit gateway ram share is created
	output6 := terraform.Output(t, terraformOptions, "transit_gateway_ram_share")
	assert.Equal(t, output6, "transit-gateway")

	//Check that three public route tables are created
    //publicRouteTables := terraform.Output(t, terraformOptions, "public_route_tables")
    //assert.Regexp(t, `^map\[live_data:\[(rtb-[a-f0-9]+){3}\] non_live_data:\[(rtb-[a-f0-9]+){3}\]\]$`, publicRouteTables)

    //Check that there are sufficient routes to the internet in the public subnets
}