module "crime_portal_gateway_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.1"

  environment-name          = var.environment-name
  team_name                 = var.team_name
  infrastructure-support    = var.infrastructure-support
  application               = "crime-portal-gateway"
  sqs_name                  = "crime_portal_gateway_queue"
  encrypt_sqs_kms           = "true"
  namespace                 = var.namespace

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.crime_portal_gateway_dead_letter_queue.sqs_arn}","maxReceiveCount": 1
  }
  EOF


  providers = {
    aws = aws.london
  }
}

module "crime_portal_gateway_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.1"

  environment-name          = var.environment-name
  team_name                 = var.team_name
  infrastructure-support    = var.infrastructure-support
  application               = "crime-portal-gateway"
  sqs_name                  = "crime_portal_gateway_dead_letter_queue"
  encrypt_sqs_kms           = "true"
  namespace                 = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "crime_portal_gateway_queue_secret" {
  metadata {
    name      = "crime_portal_gateway_queue_credentials"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.crime_portal_gateway_queue.access_key_id
    secret_access_key     = module.crime_portal_gateway_queue.secret_access_key
    sqs_id        = module.crime_portal_gateway_queue.sqs_id
    sqs_arn        = module.crime_portal_gateway_queue.sqs_arn
    user_name        = module.crime_portal_gateway_queue.user_name
    sqs_name          = module.crime_portal_gateway_queue.sqs_name
  }
}

resource "kubernetes_secret" "crime_portal_gateway_dead_letter_queue_secret" {
  metadata {
    name      = "crime_portal_gateway_dead_letter_queue_credentials"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.crime_portal_gateway_dead_letter_queue.access_key_id
    secret_access_key     = module.crime_portal_gateway_dead_letter_queue.secret_access_key
    sqs_id        = module.crime_portal_gateway_dead_letter_queue.sqs_id
    sqs_arn        = module.crime_portal_gateway_dead_letter_queue.sqs_arn
    user_name        = module.crime_portal_gateway_dead_letter_queue.user_name
    sqs_name          = module.crime_portal_gateway_dead_letter_queue.sqs_name
  }
}
