# events queue
module "sqs" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.0" # use the latest release

  # Queue configuration
  sqs_name                   = "${var.namespace}_events_queue"
  encrypt_sqs_kms            = "true"
  message_retention_seconds  = 43200 # 12 hours
  visibility_timeout_seconds = 120 # 2 minutes

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.sqs_dl.sqs_arn
    maxReceiveCount     = 3
  })

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

# events dead letter queue
module "sqs_dl" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.0" # use the latest release

  # Queue configuration
  sqs_name                   = "${var.namespace}_events_dead_letter_queue"
  encrypt_sqs_kms            = "true"
  message_retention_seconds  = 604800 # 7 days
  visibility_timeout_seconds = 120 # 2 minutes

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "sqs" {
  metadata {
    name      = "sqs-output"
    namespace = var.namespace
  }

  data = {
    queue_id  = module.sqs.sqs_id
    queue_arn  = module.sqs.sqs_arn
    queue_name = module.sqs.sqs_name
  }
}

resource "kubernetes_secret" "sqs_dl" {
  metadata {
    name      = "sqs-dl-output"
    namespace = var.namespace
  }

  data = {
    queue_id  = module.sqs_dl.sqs_id
    queue_arn  = module.sqs_dl.sqs_arn
    queue_name = module.sqs_dl.sqs_name
  }
}
