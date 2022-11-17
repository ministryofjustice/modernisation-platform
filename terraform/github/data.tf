data "github_repositories" "modernisation-platform-repositories" {
  query = "org:ministryofjustice archived:false modernisation-platform"
  sort  = "stars"
}