# Modernisation Platform: Environment definitions

This is our central store of environment definitions for each product, service, or application that sits within the Modernisation Platform.

## Provisioning a new account
You can create a new JSON file in the following format to provision an account:

```json
{
  "name": "",
  "environments": [],
  "tags": {
    "application": "",
    "business-unit": "",
    "owner": ""
  }
}
```

- `name` should be the name of your product, service, or application
- `environments` should be an array of environments required. If you require a production environment, please use the keyword `production`, as we use it to determine retention periods, backup frequency, and similar that will be different compared to non-production environments
- `tags` should be an object of the mandatory tags defined in the MoJ [Tagging Guidance](https://ministryofjustice.github.io/technical-guidance/documentation/standards/documenting-infrastructure-owners.html#tagging-your-infrastructure). You should omit `is-production` as we infer this from the environment name
