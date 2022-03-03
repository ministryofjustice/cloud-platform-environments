
module "serviceaccount" {
  source              = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=0.7.4"
  github_repositories = ["local-scorecard"]
}
