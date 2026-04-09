module "hmpps_hdc_api_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name                  = "hmpps_hdc_api_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.hmpps_hdc_api_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
  }
  EOF

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

module "hmpps_hdc_api_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name        = "hmpps_hdc_api_dlq"
  encrypt_sqs_kms = "true"

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

resource "kubernetes_secret" "hmpps_hdc_api_queue_secret" {
  metadata {
    name      = "sqs-hmpps-hdc-api-queue-secret"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.hmpps_hdc_api_queue.sqs_id
    sqs_queue_arn  = module.hmpps_hdc_api_queue.sqs_arn
    sqs_queue_name = module.hmpps_hdc_api_queue.sqs_name
  }
}

resource "kubernetes_secret" "hmpps_hdc_api_dead_letter_queue_secret" {
  metadata {
    name      = "sqs-hmpps-hdc-api-queue-dl-secret"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.hmpps_hdc_api_dead_letter_queue.sqs_id
    sqs_queue_arn  = module.hmpps_hdc_api_dead_letter_queue.sqs_arn
    sqs_queue_name = module.hmpps_hdc_api_dead_letter_queue.sqs_name
  }
}

resource "aws_ssm_parameter" "hmpps_hdc_api_queue_irsa_policy" {
  type      = "String"
  overwrite = true
  name      = "/${var.namespace}/sqs/${module.hmpps_hdc_api_queue.sqs_name}/irsa-policy-arn"
  value     = module.hmpps_hdc_api_queue.irsa_policy_arn

  tags = {
    business_unit          = var.business_unit
    application            = var.application
    is_production          = var.is_production
    team_name              = var.team_name
    namespace              = var.namespace
    environment_name       = var.environment
    infrastructure_support = var.infrastructure_support
  }
}

resource "aws_ssm_parameter" "hmpps_hdc_api_dlq_irsa_policy" {
  type      = "String"
  overwrite = true
  name      = "/${var.namespace}/sqs/${module.hmpps_hdc_api_dead_letter_queue.sqs_name}/irsa-policy-arn"
  value     = module.hmpps_hdc_api_dead_letter_queue.irsa_policy_arn

  tags = {
    business_unit          = var.business_unit
    application            = var.application
    is_production          = var.is_production
    team_name              = var.team_name
    namespace              = var.namespace
    environment_name       = var.environment
    infrastructure_support = var.infrastructure_support
  }
}
