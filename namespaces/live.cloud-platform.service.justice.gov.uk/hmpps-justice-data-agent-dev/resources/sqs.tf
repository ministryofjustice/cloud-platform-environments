########################################
# JDA request queue (CSIP -> JDA Worker)
########################################

module "jda_request_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name                   = "jda_request_queue"
  encrypt_sqs_kms            = "true"
  message_retention_seconds  = 1209600 # 14 days
  visibility_timeout_seconds = 300     # 5 mins — tune if agent runs take longer

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.jda_request_dlq.sqs_arn
    maxReceiveCount     = 3
  })

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = "hmpps-justice-data-agent" # used in queue name; keep stable
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

module "jda_request_dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name                  = "jda_request_dlq"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 7 * 24 * 3600 # 1 week

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = "hmpps-justice-data-agent" # used in queue name; keep stable
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "jda_request_queue" {
  metadata {
    name      = "sqs-jda-request-queue-secret"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.jda_request_queue.sqs_id
    sqs_queue_arn  = module.jda_request_queue.sqs_arn
    sqs_queue_name = module.jda_request_queue.sqs_name
    sqs_dlq_url    = module.jda_request_dlq.sqs_id
    sqs_dlq_arn    = module.jda_request_dlq.sqs_arn
    sqs_dlq_name   = module.jda_request_dlq.sqs_name
  }
}

#############################################
# JDA response queue (JDA Worker -> CSIP App)
#############################################

module "jda_response_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name                   = "jda_response_queue"
  encrypt_sqs_kms            = "true"
  message_retention_seconds  = 1209600 # 14 days
  visibility_timeout_seconds = 300     # 5 mins

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.jda_response_dlq.sqs_arn
    maxReceiveCount     = 3
  })

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = "hmpps-justice-data-agent" # used in queue name; keep stable
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

module "jda_response_dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name                  = "jda_response_dlq"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 7 * 24 * 3600 # 1 week

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = "hmpps-justice-data-agent" # used in queue name; keep stable
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "jda_response_queue" {
  metadata {
    name      = "sqs-jda-response-queue-secret"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.jda_response_queue.sqs_id
    sqs_queue_arn  = module.jda_response_queue.sqs_arn
    sqs_queue_name = module.jda_response_queue.sqs_name
    sqs_dlq_url    = module.jda_response_dlq.sqs_id
    sqs_dlq_arn    = module.jda_response_dlq.sqs_arn
    sqs_dlq_name   = module.jda_response_dlq.sqs_name
  }
}
