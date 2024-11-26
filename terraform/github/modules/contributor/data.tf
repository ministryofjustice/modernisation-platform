# Fetch all teams in the organization
data "github_organization_teams" "all_teams" {
    summary_only = true
}
