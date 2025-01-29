module "ims_prisoner_locations_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name                   = "ims_prisoner_locations_queue"
  encrypt_sqs_kms            = "true"
  message_retention_seconds  = 1209600
  visibility_timeout_seconds = 120

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.ims_prisoner_locations_dlq.sqs_arn}","maxReceiveCount": 3
  }

EOF

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

module "ims_prisoner_locations_dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name        = "ims_prisoner_locations_dlq"
  encrypt_sqs_kms = "true"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "ims_prisoner_locations_queue" {
  metadata {
    name      = "ims-prisoner-locations-queue-instance-output"
    namespace = var.namespace
  }

  data = {
    sqs_id   = module.ims_prisoner_locations_queue.sqs_id
    sqs_arn  = module.ims_prisoner_locations_queue.sqs_arn
    sqs_name = module.ims_prisoner_locations_queue.sqs_name
  }
}

resource "kubernetes_secret" "ims_prisoner_locations_dlq" {
  metadata {
    name      = "ims-prisoner-locations-dlq-instance-output"
    namespace = var.namespace
  }

  data = {
    sqs_id   = module.ims_prisoner_locations_dlq.sqs_id
    sqs_arn  = module.ims_prisoner_locations_dlq.sqs_arn
    sqs_name = module.ims_prisoner_locations_dlq.sqs_name
  }
}
