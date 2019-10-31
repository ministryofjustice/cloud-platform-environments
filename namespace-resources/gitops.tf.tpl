module "concourse_gitops" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-gitops"

  github_team = "${github_team}"
  namespace   = "${namespace}"

}
