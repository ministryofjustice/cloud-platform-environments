module "laa_cla_backend_training_sqs" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.8"

  environment-name       = var.environment-name
  team_name              = var.team_name
  infrastructure-support = var.infrastructure-support
  application            = var.application
  sqs_name               = "cla_backend_training_queue"
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
    access_key_id     = module.laa_cla_backend_training_sqs.access_key_id
    secret_access_key = module.laa_cla_backend_training_sqs.secret_access_key
    # the above will not be set if existing_user_name is defined
    sqs_id   = module.laa_cla_backend_training_sqs.sqs_id
    sqs_arn  = module.laa_cla_backend_training_sqs.sqs_arn
    sqs_name = module.laa_cla_backend_training_sqs.sqs_name
  }
}
