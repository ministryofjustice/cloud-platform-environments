module "concourse-gitops" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-gitops?ref=tf12"
  source_code_url               = "https://helloworld.com"
  github_team                   = "raz-test2"
  namespace                     = "helloworld-prod"
  branch                        = "master"
  concourse_basic_auth_username = var.concourse_basic_auth_username
  concourse_url                 = var.concourse_url
  concourse_basic_auth_password = var.concourse_basic_auth_password
}

