# provider "aws" {
#   region = "eu-west-2"
# }
# module "example_team_ecr_credentials" {
#   source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=2.1"
#   repo_name = "dummy-app-mourad"
#   team_name = "cloud-platform-test"
# }
# resource "kubernetes_secret" "dummy_app_mourad_ecr_credentials" {
#   metadata {
#     name      = "dummy-app-mourad-ecr-credentials-output"
#     namespace = "dummy-app-dev"
#   }
#   data {
#     access_key_id     = "${module.example_team_ecr_credentials.access_key_id}"
#     secret_access_key = "${module.example_team_ecr_credentials.secret_access_key}"
#     repo_arn          = "${module.example_team_ecr_credentials.repo_arn}"
#     repo_url          = "${module.example_team_ecr_credentials.repo_url}"
#   }
# }

