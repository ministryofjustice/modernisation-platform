data "github_repositories" "modernisation-platform-repositories" {
  query = "org:ministryofjustice modernisation-platform"
  sort  = "stars"
}