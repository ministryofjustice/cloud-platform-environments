module "prisoner_offender_index_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name                  = "prisoner_offender_index_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.prisoner_offender_index_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
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

module "prisoner_offender_index_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name        = "prisoner_offender_index_queue_dl"
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

resource "kubernetes_secret" "prisoner_offender_index_queue" {
  metadata {
    name      = "pos-idx-sqs-instance-output"
    namespace = var.namespace
  }

  data = {
    sqs_pos_url  = module.prisoner_offender_index_queue.sqs_id
    sqs_pos_arn  = module.prisoner_offender_index_queue.sqs_arn
    sqs_pos_name = module.prisoner_offender_index_queue.sqs_name
  }
}

resource "kubernetes_secret" "prisoner_offender_index_dead_letter_queue" {
  metadata {
    name      = "pos-idx-sqs-dl-instance-output"
    namespace = var.namespace
  }

  data = {
    sqs_pos_url  = module.prisoner_offender_index_dead_letter_queue.sqs_id
    sqs_pos_arn  = module.prisoner_offender_index_dead_letter_queue.sqs_arn
    sqs_pos_name = module.prisoner_offender_index_dead_letter_queue.sqs_name
  }
}
