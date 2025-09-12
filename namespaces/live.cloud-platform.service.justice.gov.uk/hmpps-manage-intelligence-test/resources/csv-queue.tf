module "ims_csv_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name                   = "ims_csv_queue"
  encrypt_sqs_kms            = "true"
  message_retention_seconds  = 1209600
  visibility_timeout_seconds = 120

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.ims_csv_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
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

module "ims_csv_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name        = "ims_csv_dl_queue"
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

resource "kubernetes_secret" "ims_csv_queue" {
  metadata {
    name      = "ims-csv-queue-instance-output"
    namespace = var.namespace
  }

  data = {
    sqs_id   = module.ims_csv_queue.sqs_id
    sqs_arn  = module.ims_csv_queue.sqs_arn
    sqs_name = module.ims_csv_queue.sqs_name
  }
}

resource "kubernetes_secret" "ims_csv_dead_letter_queue" {
  metadata {
    name      = "ims-csv-dlq-instance-output"
    namespace = var.namespace
  }

  data = {
    sqs_id   = module.ims_csv_dead_letter_queue.sqs_id
    sqs_arn  = module.ims_csv_dead_letter_queue.sqs_arn
    sqs_name = module.ims_csv_dead_letter_queue.sqs_name
  }
}
