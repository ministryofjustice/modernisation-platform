# Resource discovery

This command inventories non-network AWS resources in the account represented by the current AWS credentials. Account selection and role assumption are handled outside the command, allowing the same binary to run locally or in GitHub Actions.

The inventory is sourced from AWS Config. It includes resource types that the platform's configuration recorders record and AWS Config advanced query supports. It does not make service-specific list calls and cannot return resource types that AWS Config does not record or expose to advanced queries.

## Run

```bash
go run . \
  --account-name example-development
```

The default query covers the five regions in which the platform baseline enables AWS Config:

- `eu-central-1`
- `eu-west-1`
- `eu-west-2`
- `eu-west-3`
- `us-east-1`

Use `--regions` to override that comma-separated list. Use `--resource-type` to return one exact AWS Config resource type instead of all types:

```bash
go run . \
  --account-name example-development \
  --regions eu-west-2,us-east-1 \
  --resource-type AWS::RDS::DBInstance
```

`--account-name` defaults to `ACCOUNT_NAME`, then `TF_WORKSPACE`.

The command loads credentials using the standard AWS SDK credential chain. For local use, select a suitable AWS profile before running it. In GitHub Actions, configure OIDC credentials before invoking the command.

Network infrastructure is excluded after querying AWS Config. The exclusion policy covers VPC constructs, routing and DNS, load balancers, edge networking, network firewalls, service meshes, and service-specific subnet or VPC attachment resources. The complete policy is defined and tested in `network.go` and `network_test.go`.

## GitHub Actions workflow

Run the `Resource Discovery` workflow manually from the Actions tab. It accepts these inputs:

| Input | Description |
| --- | --- |
| `accounts` | A comma-separated list of application names or full account names, or `all`. An application name expands to all of its eligible environments. This input has no default to prevent accidental organisation-wide runs. |
| `business_unit` | An optional business-unit filter. When application or account names are also supplied, both filters must match. |
| `resource_type` | An exact AWS Config resource type, or `all`. |
| `regions` | A comma-separated list of AWS Config regions. Defaults to the five platform baseline regions. |

Examples for `accounts` include `laa-oem`, `laa-oem-test`, `laa-oem-test,example-production`, and `all`. Selecting `laa-oem` expands to all eligible environments defined in `environments/laa-oem.json`. Selecting `all` with `business_unit` set to `LAA` runs discovery only in LAA accounts.

The workflow summary displays counts by resource type and account. Each account produces a short-lived JSON artifact, and the final `resource-discovery-results` artifact contains the combined results in both JSON and CSV format for 14 days.

The member bootstrap must be deployed to a target account before the first run so that the `github-actions-resource-discovery` OIDC role is available.

## Output

Results are written to standard output as a JSON array:

```json
[
  {
    "account_name": "example-development",
    "account_id": "123456789012",
    "region": "eu-west-2",
    "resource_type": "AWS::RDS::DBInstance",
    "identifier": "example-database",
    "name": "example-database",
    "arn": "arn:aws:rds:eu-west-2:123456789012:db:example-database"
  }
]
```

Results are sorted by resource type, region, and identifier. Resources with the same ARN recorded in more than one region are returned once. An account with no matching resources returns `[]`.

## IAM permissions

The assumed role requires the read-only action `config:SelectResourceConfig` with resource `*`.

## Test

```bash
go test ./...
go vet ./...
```