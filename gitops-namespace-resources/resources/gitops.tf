module "concourse-gitops" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-gitops"
  source_code_url               = "${source_code_url}"
  github_team                   = "${github_team}"
  namespace                     = "${namespace}"
  branch                        = "main"
  concourse_basic_auth_username = var.concourse_basic_auth_username
  concourse_url                 = var.concourse_url
  concourse_basic_auth_password = var.concourse_basic_auth_password
}
