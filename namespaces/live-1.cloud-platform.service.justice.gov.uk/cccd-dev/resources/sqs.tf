# module "responses_for_cccd" {
#   source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=1.0"

#   environment-name       = "dev"
#   team_name              = "laa-get-paid"
#   infrastructure-support = "crowncourtdefence@digtal.justice.gov.uk"
#   application            = "cccd"
#   aws_region             = "eu-west-2"
# }

# resource "kubernetes_secret" "responses_for_cccd" {
#   metadata {
#     name      = "responses-for-cccd-sqs"
#     namespace = "cccd-dev"
#   }

#   data {
#     access_key_id     = "${module.responses_for_cccd.access_key_id}"
#     secret_access_key = "${module.responses_for_cccd.secret_access_key}"
#     sqs_id            = "${module.responses_for_cccd.sqs_id}"
#     sqs_arn           = "${module.responses_for_cccd.sqs_arn}"
#   }
# }
