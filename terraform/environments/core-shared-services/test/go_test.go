package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"regexp"
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

	//Check that one public route table is created
    publicRouteTables := terraform.Output(t, terraformOptions, "public_route_tables")
    assert.Regexp(t, `^map\[live_data:\[(rtb-[a-f0-9]+){1}\] non_live_data:\[(rtb-[a-f0-9]+){1}\]\]$`, publicRouteTables)

	//Test public igw cidr
	output1 := terraform.Output(t, terraformOptions, "public_igw_route")
	assert.Equal(t, output1, "map[live_data:0.0.0.0/0 non_live_data:0.0.0.0/0]")

	//Test tgw-subnet count. There should be 3
	output3 := terraform.Output(t, terraformOptions, "tgw_subnet_ids")
	assert.Equal(t, output3, "3")

	//Test non-tgw-subnets count. There should be 9
	output4 := terraform.Output(t, terraformOptions, "non_tgw_subnet_ids")
	assert.Equal(t, output4, "9")

	//Check the correct CIDR address have been added
	output5 := terraform.Output(t, terraformOptions, "vpc_cidrs")
	assert.Equal(t, output5, "map[live_data:10.20.64.0/19 non_live_data:10.20.96.0/19]")

}

func TestInstanceSchedulerLambda(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "./test_terraform",
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	functionName := terraform.Output(t, terraformOptions, "function_name")
	resultCode := terraform.Output(t, terraformOptions, "execution_result")
	// memberList := terraform.Output(t, terraformOptions, "member_account")

	assert.Regexp(t, regexp.MustCompile(`^instance-scheduler-lambda-function*`), functionName)
	assert.Regexp(t, regexp.MustCompile(`^200*`), resultCode)
	// assert.Regexp(t, regexp.MustCompile(`^testing-test*`), memberList)
}
