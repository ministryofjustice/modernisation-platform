# Load balancer and WAF logging discovery

A separate, read-only inventory of live ALB/NLB access-log settings and WAFv2
logging settings. The existing Resource Discovery workflow and AWS Config script
are unchanged. This script uses AWS CLI service APIs rather than AWS Config, so
it does not depend on Config recording these resources.

## Run the workflow

Deploy the member bootstrap change first to grant the additional read-only
ELB/WAF permissions to the existing `github-actions-resource-discovery` OIDC role
in each target account. No new OIDC role is needed.
Then run **Load Balancer and WAF Logging Discovery** from the GitHub Actions tab:

| Input | Description |
| --- | --- |
| `accounts` | Application names, full account names, or `all`. Required, with no default to prevent accidental organisation-wide runs. |
| `business_unit` | `all` or a business-unit filter, intersected with the account selection. |
| `regions` | Comma-separated regions for ALB/NLB and regional WAF discovery. Defaults to `eu-central-1,eu-west-1,eu-west-2,eu-west-3,us-east-1`. CloudFront-scoped WAF is always queried once via `us-east-1`, even if that region is omitted. |

For example, `accounts=laa-oem` selects all eligible environments for that
application; `accounts=all` and `business_unit=LAA` selects all eligible LAA
accounts. Selection includes `member` and `member-unrestricted` accounts present
in environment management, not core accounts. To cover other enabled AWS
regions, include them explicitly; the default is not an all-region scan.

The `lb-waf-discovery-results` artifact is retained for 14 days and contains:

- `logging-discovery.json`: completed account metadata, coverage counts,
  `complete`, `load_balancers`, and `web_acls`.
- `load-balancers.csv`: ALBs/NLBs, access logging enabled/disabled, configured
  S3 bucket/prefix, access-log URI, scheme, DNS name and associated WAF ACL ARNs.
- `web-acls.csv`: all regional and CloudFront-scoped WAFv2 ACLs in scope,
  logging enabled/disabled, destination ARNs, full logging configurations
  (including filters, redacted fields and log scope), and associated ALB ARNs.
  ACLs without ALB associations are included. Customer, Security Lake and
  CloudWatch telemetry rule-managed logging configurations are queried.

An account with no resources is still counted as completed. API errors fail the
account job rather than reporting logging as disabled. The final workflow fails
if any discovery block fails or an account artifact is missing; it still uploads
available results, explicitly marked incomplete when account coverage is missing.
Check the workflow result as well as the report's coverage before relying on it.

## Run locally

Requires Bash, a current AWS CLI v2 supporting the WAF log scopes above, `jq`,
and credentials for the target account:

```bash
AWS_PROFILE=example-development \
  bash scripts/internal/load-balancer-discovery/discover.sh \
  example-development eu-west-2,us-east-1 > logging-discovery.json
```

The first argument labels the account and defaults to `ACCOUNT_NAME` when omitted;
the account ID comes from STS. The second argument overrides the region list.
ELB uses AWS CLI automatic pagination. WAF list operations explicitly follow
`NextMarker` for both ACLs and logging configurations.
The script writes a single account object to stdout only after all queries
succeed, and progress/errors to stderr. It does not read or modify log contents.

In addition to its existing AWS Config query permission, the shared discovery
role permits:

- `elasticloadbalancing:DescribeLoadBalancers`
- `elasticloadbalancing:DescribeLoadBalancerAttributes`
- `wafv2:ListWebACLs`
- `wafv2:ListLoggingConfigurations`
- `wafv2:ListResourcesForWebACL`

The script also calls `sts:GetCallerIdentity`, which requires no explicit allow.
It does not grant access to S3 objects, CloudWatch log events, or Firehose data.
Classic ELBs and Gateway Load Balancers are excluded.

## Using the inventory for incident investigation

This inventory can locate potential evidence for investigations such as the
reported CVE-2026-109618 and CVE-2026-109619 issues. It does not validate those CVE
identifiers, determine affected PHP versions, or detect exploitation.

- ALB access logs can provide HTTP request URLs and response metadata, but not
  request bodies. Use the reported S3 URI followed by `YYYY/MM/DD/` to locate
  candidate logs for the incident window.
- NLB access logs cover TLS listeners only. They are connection/TLS metadata,
  not HTTP request logs; logging enabled does not mean PHP requests are visible.
- WAF logging destinations can be CloudWatch Logs, S3 or Firehose. The report
  preserves destination ARNs; a Firehose ARN is not the downstream storage
  location, which must be checked separately.
- Logging filters can drop events and redaction can remove useful fields.
  WAF logs do not guarantee full request-body visibility. Sampled requests and
  CloudWatch metrics are not substitutes for enabled WAF logging.
- WAF associations are reported for regional ALBs only. NLBs do not support WAF.
  CloudFront ACLs are inventoried, but distribution associations and CloudFront
  access-log settings are not queried.
- Current configuration does not prove logs existed during the incident window,
  were delivered successfully, or remain retained. Disabled logging cannot be
  enabled retroactively. Check destination permissions, retention and historical
  configuration, and correlate with application/web-server logs.

## Tests

Tests use a fake AWS CLI and make no AWS calls:

```bash
bash scripts/internal/load-balancer-discovery/tests/test.sh
shellcheck scripts/internal/load-balancer-discovery/discover.sh \
  scripts/internal/load-balancer-discovery/tests/*.sh
actionlint .github/workflows/load-balancer-discovery.yml \
  .github/workflows/reusable-load-balancer-discovery.yml
```
