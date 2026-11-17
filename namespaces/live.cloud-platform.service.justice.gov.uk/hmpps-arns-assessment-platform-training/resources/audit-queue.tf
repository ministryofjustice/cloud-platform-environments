# Training-owned audit sink, used instead of the HAAR dev audit queue
module "hmpps_arns_training_audit_sink" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.3"

  sqs_name        = "hmpps-arns-training-audit-sink"
  encrypt_sqs_kms = true

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "sqs_hmpps_audit_secret" {
  metadata {
    name      = "sqs-hmpps-audit-secret"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.hmpps_arns_training_audit_sink.sqs_id
    sqs_queue_arn  = module.hmpps_arns_training_audit_sink.sqs_arn
    sqs_queue_name = module.hmpps_arns_training_audit_sink.sqs_name
  }
}

resource "kubernetes_secret" "hmpps_sqs_audit_queue" {
  metadata {
    name      = "hmpps-sqs-audit-queue"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.hmpps_arns_training_audit_sink.sqs_id
    sqs_queue_arn  = module.hmpps_arns_training_audit_sink.sqs_arn
    sqs_queue_name = module.hmpps_arns_training_audit_sink.sqs_name
  }
}
