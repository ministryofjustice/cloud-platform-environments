module "laa_cla_backend_staging_sqs" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.0"

  environment-name          = var.environment-name
  team_name                 = var.team_name
  infrastructure-support    = var.infrastructure-support
  application               = var.application
  sqs_name                  = "cla_backend_staging_queue"
  encrypt_sqs_kms           = "false"

  providers = {
    aws = aws.london
  }
}
