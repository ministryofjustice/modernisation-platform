locals {
  all_team_slugs = [
    for team in data.github_organization_teams.all_teams.teams : team.slug
  ]
}
