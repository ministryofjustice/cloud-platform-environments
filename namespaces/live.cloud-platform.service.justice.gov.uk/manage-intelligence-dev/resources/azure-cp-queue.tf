module "ims_azure_cp_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.11.0"

  environment-name           = var.environment-name
  team_name                  = var.team_name
  infrastructure-support     = var.infrastructure_support
  application                = var.application
  sqs_name                   = "ims_azure_cp_queue.fifo"
  fifo_queue                 = true
  encrypt_sqs_kms            = "true"
  message_retention_seconds  = 1209600
  visibility_timeout_seconds = 120
  namespace                  = var.namespace


  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.ims_azure_cp_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
  }

EOF

  providers = {
    aws = aws.london
  }
}

module "ims_azure_cp_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.11.0"

  environment-name       = var.environment-name
  team_name              = var.team_name
  infrastructure-support = var.infrastructure_support
  application            = var.application
  sqs_name               = "ims_azure_cp_dl_queue.fifo"
  fifo_queue             = true
  encrypt_sqs_kms        = "true"
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "ims_azure_cp_queue" {
  metadata {
    name      = "ims-index-batch-queue-instance-output"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.ims_azure_cp_queue.access_key_id
    secret_access_key = module.ims_azure_cp_queue.secret_access_key
    sqs_id            = module.ims_azure_cp_queue.sqs_id
    sqs_arn           = module.ims_azure_cp_queue.sqs_arn
    sqs_name          = module.ims_azure_cp_queue.sqs_name
  }
}

resource "kubernetes_secret" "ims_azure_cp_dead_letter_queue" {
  metadata {
    name      = "ims-index-batch-dlq-instance-output"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.ims_azure_cp_dead_letter_queue.access_key_id
    secret_access_key = module.ims_azure_cp_dead_letter_queue.secret_access_key
    sqs_id            = module.ims_azure_cp_dead_letter_queue.sqs_id
    sqs_arn           = module.ims_azure_cp_dead_letter_queue.sqs_arn
    sqs_name          = module.ims_azure_cp_dead_letter_queue.sqs_name
  }
}
