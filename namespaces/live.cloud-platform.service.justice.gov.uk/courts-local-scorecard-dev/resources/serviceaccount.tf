
module "serviceaccount" {
  source = "../"
  namespace           = "courts-local-scorecard-dev"
  github_repositories = ["local-scorecard"]
}
