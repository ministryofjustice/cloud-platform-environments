module "equip_migration_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name                   = "equip_migration_queue"
  encrypt_sqs_kms            = "true"
  message_retention_seconds  = 86400 # 1 days
  visibility_timeout_seconds = 300   # 5 mins

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.equip_migration_dlq.sqs_arn}","maxReceiveCount": 1
  }
  EOF

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "equip_migration_queue" {
  metadata {
    name      = "sqs-equip-migration-queue-secret"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.equip_migration_queue.sqs_id
    sqs_queue_arn  = module.equip_migration_queue.sqs_arn
    sqs_queue_name = module.equip_migration_queue.sqs_name
  }
}


module "equip_migration_dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name                   = "equip_migration_dlq"
  encrypt_sqs_kms            = "true"
  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "equip_migration_dlq" {
  metadata {
    name      = "sqs-equip-migration-dlq-secret"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.equip_migration_dlq.sqs_id
    sqs_queue_arn  = module.equip_migration_dlq.sqs_arn
    sqs_queue_name = module.equip_migration_dlq.sqs_name
  }
}

module "equip_data_quality_dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name                   = "equip_data_quality_dlq"
  encrypt_sqs_kms            = "true"
  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "equip_data_quality_dlq" {
  metadata {
    name      = "sqs-equip-data-quality-dlq-secret"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.equip_data_quality_dlq.sqs_id
    sqs_queue_arn  = module.equip_data_quality_dlq.sqs_arn
    sqs_queue_name = module.equip_data_quality_dlq.sqs_name
  }
}

module "equip_data_quality_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name                   = "equip_data_quality_queue"
  encrypt_sqs_kms            = "true"
  message_retention_seconds  = 86400 # 1 days
  visibility_timeout_seconds = 300   # 5 mins

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.equip_data_quality_dlq.sqs_arn}","maxReceiveCount": 1
  }
  EOF

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "equip_data_quality_queue" {
  metadata {
    name      = "sqs-equip-data-quality-queue-secret"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.equip_data_quality_queue.sqs_id
    sqs_queue_arn  = module.equip_data_quality_queue.sqs_arn
    sqs_queue_name = module.equip_data_quality_queue.sqs_name
  }
}
