module "concourse-gitops" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-gitops"
  source_code_url               = "https://foo.bar.baz"
  github_team                   = "webops"
  namespace                     = "make-gitops-namespace-test-dev"
  branch                        = "main"
  concourse_basic_auth_username = var.concourse_basic_auth_username
  concourse_url                 = var.concourse_url
  concourse_basic_auth_password = var.concourse_basic_auth_password
}
