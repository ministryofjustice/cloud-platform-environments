module "crime-portal-gateway-queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.12.0"

  # Queue configuration
  sqs_name        = "crime-portal-gateway-queue"
  encrypt_sqs_kms = "true"

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.crime-portal-gateway-dead-letter-queue.sqs_arn}","maxReceiveCount": 3
  }
  EOF

  # Tags
  business_unit          = var.business_unit
  application            = "crime-portal-gateway"
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

module "crime-portal-gateway-dead-letter-queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.12.0"

  # Queue configuration
  sqs_name                  = "crime-portal-gateway-dead-letter-queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600

  # Tags
  business_unit          = var.business_unit
  application            = "crime-portal-gateway"
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "crime-portal-gateway-queue-secret" {
  metadata {
    name      = "crime-portal-gateway-queue-credentials"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.crime-portal-gateway-queue.access_key_id
    secret_access_key = module.crime-portal-gateway-queue.secret_access_key
    sqs_id            = module.crime-portal-gateway-queue.sqs_id
    sqs_arn           = module.crime-portal-gateway-queue.sqs_arn
    user_name         = module.crime-portal-gateway-queue.user_name
    sqs_name          = module.crime-portal-gateway-queue.sqs_name
  }
}

resource "kubernetes_secret" "crime-portal-gateway-dead-letter-queue-secret" {
  metadata {
    name      = "crime-portal-gateway-dead-letter-queue-credentials"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.crime-portal-gateway-dead-letter-queue.access_key_id
    secret_access_key = module.crime-portal-gateway-dead-letter-queue.secret_access_key
    sqs_id            = module.crime-portal-gateway-dead-letter-queue.sqs_id
    sqs_arn           = module.crime-portal-gateway-dead-letter-queue.sqs_arn
    user_name         = module.crime-portal-gateway-dead-letter-queue.user_name
    sqs_name          = module.crime-portal-gateway-dead-letter-queue.sqs_name
  }
}
