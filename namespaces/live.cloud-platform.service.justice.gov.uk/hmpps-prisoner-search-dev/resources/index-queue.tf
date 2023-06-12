module "hmpps_prisoner_search_index_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.11.0"

  environment-name          = var.environment
  team_name                 = var.team_name
  infrastructure-support    = var.infrastructure_support
  application               = var.application
  sqs_name                  = "hmpps_prisoner_search_index_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600
  namespace                 = var.namespace

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.hmpps_prisoner_search_index_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
  }

EOF

  providers = {
    aws = aws.london
  }
}

module "hmpps_prisoner_search_index_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.11.0"

  environment-name       = var.environment
  team_name              = var.team_name
  infrastructure-support = var.infrastructure_support
  application            = var.application
  sqs_name               = "hmpps_prisoner_search_index_queue_dl"
  encrypt_sqs_kms        = "true"
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "hmpps_prisoner_search_index_queue" {
  metadata {
    name      = "prisoner-search-indexer-queue"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url       = module.hmpps_prisoner_search_index_queue.sqs_id
    sqs_queue_arn       = module.hmpps_prisoner_search_index_queue.sqs_arn
    sqs_queue_name      = module.hmpps_prisoner_search_index_queue.sqs_name
  }
}

resource "kubernetes_secret" "hmpps_prisoner_search_index_dead_letter_queue" {
  metadata {
    name      = "prisoner-search-indexer-dlq"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url       = module.hmpps_prisoner_search_index_dead_letter_queue.sqs_id
    sqs_queue_arn       = module.hmpps_prisoner_search_index_dead_letter_queue.sqs_arn
    sqs_queue_name      = module.hmpps_prisoner_search_index_dead_letter_queue.sqs_name
  }
}
