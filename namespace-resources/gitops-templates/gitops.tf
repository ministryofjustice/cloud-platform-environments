module "concourse-gitops" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-gitops"
  github_team                   = "${var.github_team}"
  namespace                     = "${var.namespace}"
  concourse_basic_auth_username = "TF_VAR_CONCOURSE_USER"
  concourse_url                 = "TF_VAR_CONCOURSE_URL"
  concourse_basic_auth_password = "TF_VAR_CONCOUSE_PASSWORD"
}
