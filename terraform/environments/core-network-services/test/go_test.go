package test

import (
	"fmt"
	"path"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	tfPlan "github.com/hashicorp/terraform/plans/planfile"
	"github.com/stretchr/testify/assert"
)

//################################################
//# The test uses the output from a Terraform plan
//################################################

func TestTerraformPlan(t *testing.T) {

	// Retryable errors in terraform testing.
	tfOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../",
	})

	// Refresh terraform to update plan
	terraform.RunTerraformCommand(t, tfOptions, "refresh")

	// Output a local copy of the plan to read
	tfPlanOutput := "terraform.tfplan"
	terraform.RunTerraformCommand(t, tfOptions, terraform.FormatArgs(tfOptions, "plan", "-out="+tfPlanOutput)...)

	// Read and parse the plan output
	reader, err := tfPlan.Open(path.Join(tfOptions.TerraformDir, tfPlanOutput))

	if err != nil {
		t.Fatal(err)
	}
	defer reader.Close()

	plan, _ := reader.ReadPlan()

	if plan.Changes.Empty() {
		t.Fatal("Empty plan outcome")

	}
	fmt.Printf("Checking terrafom plan...")

	// Map to hold plan output values
	outputs := map[string]string{}

	for _, res := range plan.Changes.Outputs {

		outputs[res.Addr.OutputValue.Name] = terraform.Output(t, tfOptions, res.Addr.OutputValue.Name)

	}

	// List all outputs for Terraform
	for key, value := range outputs {

		fmt.Println("Terraform Outputs:", key, "=", value)
	}

	//##########################################
	//# Test Terraform outputs - non-live-data
	//##########################################

	//Test private route tables
	var privateRouteTableData = []string{
		"non_live_data-private-eu-west-2a",
		"non_live_data-private-eu-west-2b",
		"non_live_data-private-eu-west-2c",
	}

	for _, element := range privateRouteTableData {

		assert.Contains(t, outputs["private_route_tables"], element)
	}

	//Test public igw cidr
	assert.Equal(t, outputs["public_igw_route"], "0.0.0.0/0")

	//Test tgw-subnet count. There should be 3
	assert.Equal(t, outputs["tgw_subnet_ids"], "3")

	//Test non-tgw-subnets count. There should be 9
	assert.Equal(t, outputs["non_tgw_subnet_ids"], "9")

	//Check we have a live and non-live VPC
	assert.Contains(t, outputs["vpcs"], "live_data")
	assert.Contains(t, outputs["vpcs"], "non_live_data")

	//Check the correct CIDR address have been added
	assert.Equal(t, "10.230.0.0/19", outputs["live_cidr"])
	assert.Equal(t, "10.230.32.0/19", outputs["nonlive-cidr"])

	//Check the transit gateway has been setup
	assert.Equal(t, "tgw-053d9dd7f1222a554", outputs["transit-gateway"])

}

//to run  aws-vault exec mod -- go test | grep 'Plan:' |  sed 's/^.*Plan:/Plan:/'
