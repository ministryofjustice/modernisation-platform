package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestLiveCidr(t *testing.T) {
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../output.tf",
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndPlan(t, terraformOptions)

	output := terraform.Output(t, terraformOptions, "live_cidr")
	assert.Equal(t, "10.230.128.0/19", output)

}

func TestNonLiveCidr(t *testing.T) {
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../output.tf",
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndPlan(t, terraformOptions)

	output := terraform.Output(t, terraformOptions, "nonlive-cidr")
	assert.Equal(t, "10.230.32.0/19", output)

}

func TestTransitGateway(t *testing.T) {
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../output.tf",
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndPlan(t, terraformOptions)

	output := terraform.Output(t, terraformOptions, "transit-gateway")
	assert.Equal(t, "transit-gateway", output)

}
