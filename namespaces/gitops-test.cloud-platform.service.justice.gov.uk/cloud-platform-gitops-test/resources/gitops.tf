module "concourse-gitops" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-gitops"
  source_code_url               = "https://github.com/ministryofjustice/cloud-platform-gitops-test"
  github_team                   = "webops"
  namespace                     = "cloud-platform-gitops-test"
  branch                        = "master"
  concourse_basic_auth_username = "${var.concourse_basic_auth_username}"
  concourse_url                 = "${var.concourse_url}"
  concourse_basic_auth_password = "${var.concourse_basic_auth_password}"
}
