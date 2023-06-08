

module "hmpps_audit_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.11.0"

  environment-name          = var.environment-name
  team_name                 = var.team_name
  infrastructure-support    = var.infrastructure_support
  application               = var.application
  sqs_name                  = "hmpps_audit_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600
  namespace                 = var.namespace

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.hmpps_audit_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
  }

EOF


  providers = {
    aws = aws.london
  }
}


module "hmpps_audit_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.11.0"

  environment-name       = var.environment-name
  team_name              = var.team_name
  infrastructure-support = var.infrastructure_support
  application            = var.application
  sqs_name               = "hmpps_audit_dlq"
  encrypt_sqs_kms        = "true"
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "hmpps_audit_queue_secret" {
  metadata {
    name      = "sqs-audit-queue-secret"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.hmpps_audit_queue.access_key_id
    secret_access_key = module.hmpps_audit_queue.secret_access_key
    sqs_queue_url     = module.hmpps_audit_queue.sqs_id
    sqs_queue_arn     = module.hmpps_audit_queue.sqs_arn
    sqs_queue_name    = module.hmpps_audit_queue.sqs_name
  }
}

resource "kubernetes_secret" "hmpps_audit_dead_letter_queue_secret" {
  metadata {
    name      = "sqs-audit-queue-dl-secret"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.hmpps_audit_dead_letter_queue.access_key_id
    secret_access_key = module.hmpps_audit_dead_letter_queue.secret_access_key
    sqs_queue_url     = module.hmpps_audit_dead_letter_queue.sqs_id
    sqs_queue_arn     = module.hmpps_audit_dead_letter_queue.sqs_arn
    sqs_queue_name    = module.hmpps_audit_dead_letter_queue.sqs_name
  }
}
