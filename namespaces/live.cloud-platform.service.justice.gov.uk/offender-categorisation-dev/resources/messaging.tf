module "risk_profiler_change" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.12.0"

  # Queue configuration
  sqs_name        = "risk_profiler_change"
  encrypt_sqs_kms = "false"

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.risk_profiler_change_dead_letter_queue.sqs_arn}","maxReceiveCount": 1
  }

EOF

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
}

module "risk_profiler_change_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.12.0"

  # Queue configuration
  sqs_name        = "risk_profiler_change_dl"
  encrypt_sqs_kms = "false"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "risk_profiler_change" {
  metadata {
    name      = "rp-sqs-instance-output"
    namespace = var.namespace
  }

  data = {
    sqs_rpc_url       = module.risk_profiler_change.sqs_id
    sqs_rpc_arn       = module.risk_profiler_change.sqs_arn
    sqs_rpc_name      = module.risk_profiler_change.sqs_name
    sqs_rpc_dlq_url   = module.risk_profiler_change_dead_letter_queue.sqs_id
    sqs_rpc_dlq_arn   = module.risk_profiler_change_dead_letter_queue.sqs_arn
    sqs_rpc_dlq_name  = module.risk_profiler_change_dead_letter_queue.sqs_name
  }
}

resource "kubernetes_secret" "risk_profiler_change_dead_letter_queue" {
  metadata {
    name      = "rp-sqs-dl-instance-output"
    namespace = var.namespace
  }

  data = {
    sqs_rpc_url       = module.risk_profiler_change_dead_letter_queue.sqs_id
    sqs_rpc_arn       = module.risk_profiler_change_dead_letter_queue.sqs_arn
    sqs_rpc_name      = module.risk_profiler_change_dead_letter_queue.sqs_name
  }
}
