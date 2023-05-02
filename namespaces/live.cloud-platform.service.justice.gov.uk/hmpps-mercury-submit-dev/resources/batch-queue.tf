module "mercsubmit_index_batch_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.10.1"

  environment-name           = var.environment
  team_name                  = var.team_name
  infrastructure-support     = var.infrastructure_support
  application                = var.application
  sqs_name                   = "mercsubmit_index_batch_queue_${var.environment}"
  encrypt_sqs_kms            = "true"
  message_retention_seconds  = 1209600
  visibility_timeout_seconds = 120
  namespace                  = var.namespace


  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.mercsubmit_index_batch_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
  }
  
EOF

  providers = {
    aws = aws.london
  }
}

module "mercsubmit_index_batch_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.10.1"

  environment-name       = var.environment
  team_name              = var.team_name
  infrastructure-support = var.infrastructure_support
  application            = var.application
  sqs_name               = "mercsubmit_index_batch_dl_queue_${var.environment}"
  encrypt_sqs_kms        = "true"
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "mercsubmit_index_batch_queue" {
  metadata {
    name      = "mercsubmit-index-batch-queue-instance-output"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.mercsubmit_index_batch_queue.access_key_id
    secret_access_key = module.mercsubmit_index_batch_queue.secret_access_key
    sqs_id            = module.mercsubmit_index_batch_queue.sqs_id
    sqs_arn           = module.mercsubmit_index_batch_queue.sqs_arn
    sqs_name          = module.mercsubmit_index_batch_queue.sqs_name
  }
}

resource "kubernetes_secret" "mercsubmit_index_batch_dead_letter_queue" {
  metadata {
    name      = "mercsubmit-index-batch-dlq-instance-output"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.mercsubmit_index_batch_dead_letter_queue.access_key_id
    secret_access_key = module.mercsubmit_index_batch_dead_letter_queue.secret_access_key
    sqs_id            = module.mercsubmit_index_batch_dead_letter_queue.sqs_id
    sqs_arn           = module.mercsubmit_index_batch_dead_letter_queue.sqs_arn
    sqs_name          = module.mercsubmit_index_batch_dead_letter_queue.sqs_name
  }
}

