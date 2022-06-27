module "migration_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.6"

  environment-name           = var.environment
  team_name                  = var.team_name
  infrastructure-support     = var.infrastructure_support
  application                = var.application
  sqs_name                   = "migration_queue"
  encrypt_sqs_kms            = "true"
  message_retention_seconds  = 1209600
  visibility_timeout_seconds = 120
  namespace                  = var.namespace


  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.migration_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
  }

EOF

  providers = {
    aws = aws.london
  }
}

module "migration_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.6"

  environment-name       = var.environment
  team_name              = var.team_name
  infrastructure-support = var.infrastructure_support
  application            = var.application
  sqs_name               = "migration_dlq"
  encrypt_sqs_kms        = "true"
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "migration_queue" {
  metadata {
    name      = "sqs-migration-queue"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.migration_queue.access_key_id
    secret_access_key = module.migration_queue.secret_access_key
    sqs_id            = module.migration_queue.sqs_id
    sqs_arn           = module.migration_queue.sqs_arn
    sqs_name          = module.migration_queue.sqs_name
  }
}

resource "kubernetes_secret" "migration_dead_letter_queue" {
  metadata {
    name      = "sqs-migration-dlq"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.migration_dead_letter_queue.access_key_id
    secret_access_key = module.migration_dead_letter_queue.secret_access_key
    sqs_id            = module.migration_dead_letter_queue.sqs_id
    sqs_arn           = module.migration_dead_letter_queue.sqs_arn
    sqs_name          = module.migration_dead_letter_queue.sqs_name
  }
}
