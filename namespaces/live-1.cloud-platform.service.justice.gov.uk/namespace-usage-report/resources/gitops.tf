module "concourse-gitops" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-gitops:add/gitops-manager"
  source_code_url               = "https://github.com/ministryofjustice/cloud-platform-namespace-usage-report"
  github_team                   = "webops"
  namespace                     = "namespace-usage-report"
  branch                        = "master"
  concourse_basic_auth_username = var.concourse_basic_auth_username
  concourse_url                 = var.concourse_url
  concourse_basic_auth_password = var.concourse_basic_auth_password
}
