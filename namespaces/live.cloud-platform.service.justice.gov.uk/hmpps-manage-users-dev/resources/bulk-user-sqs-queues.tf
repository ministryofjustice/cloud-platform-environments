module "manage_users_bulk_user_queue" {

  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name                  = "hmpps_manage_users_bulk_user_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.manage_users_bulk_user_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
  }

EOF

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

module "manage_users_bulk_user_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name        = "hmpps_manage_users_bulk_user_dlq"
  encrypt_sqs_kms = "true"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "manage_users_bulk_user_queue_secret" {
  metadata {
    name      = "sqs-manage-users-bulk-user-job-queue-secret"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.manage_users_bulk_user_queue.sqs_id
    sqs_queue_arn  = module.manage_users_bulk_user_queue.sqs_arn
    sqs_queue_name = module.manage_users_bulk_user_queue.sqs_name
  }
}

resource "kubernetes_secret" "manage_users_bulk_user_dead_letter_queue_secret" {
  metadata {
    name      = "sqs-audit-queue-dl-secret"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.manage_users_bulk_user_dead_letter_queue.sqs_id
    sqs_queue_arn  = module.manage_users_bulk_user_dead_letter_queue.sqs_arn
    sqs_queue_name = module.manage_users_bulk_user_dead_letter_queue.sqs_name
  }
}

module "manage_users_bulk_user_item_queue" {

  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name                  = "hmpps_manage_users_bulk_user_item_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.manage_users_bulk_user_item_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
  }

EOF

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

module "manage_users_bulk_user_item_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name        = "hmpps_manage_users_bulk_user_item_dlq"
  encrypt_sqs_kms = "true"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "manage_users_bulk_user_item_queue_secret" {
  metadata {
    name      = "sqs-manage-users-bulk-user-item-job-queue-secret"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.manage_users_bulk_user_item_queue.sqs_id
    sqs_queue_arn  = module.manage_users_bulk_user_item_queue.sqs_arn
    sqs_queue_name = module.manage_users_bulk_user_item_queue.sqs_name
  }
}

resource "kubernetes_secret" "manage_users_bulk_user_item_dead_letter_queue_secret" {
  metadata {
    name      = "sqs-audit-queue-dl-secret"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.manage_users_bulk_user_item_dead_letter_queue.sqs_id
    sqs_queue_arn  = module.manage_users_bulk_user_item_dead_letter_queue.sqs_arn
    sqs_queue_name = module.manage_users_bulk_user_item_dead_letter_queue.sqs_name
  }
}
