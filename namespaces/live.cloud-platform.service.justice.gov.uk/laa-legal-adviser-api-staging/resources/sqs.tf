module "laalaa_sqs" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.11.0"

  environment-name       = var.environment-name
  team_name              = var.team_name
  infrastructure-support = var.email
  application            = var.application
  sqs_name               = "laalaa_staging_queue"
  encrypt_sqs_kms        = "false"
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}
resource "kubernetes_secret" "sqs" {
  metadata {
    name      = "sqs"
    namespace = var.namespace
  }

  data = {
    sqs_id   = module.laalaa_sqs.sqs_id
    sqs_arn  = module.laalaa_sqs.sqs_arn
    sqs_name = module.laalaa_sqs.sqs_name
  }
}
