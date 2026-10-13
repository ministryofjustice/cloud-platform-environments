module "hmpps_knowledge_base_s3_input" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.1"
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "hmpps_knowledge_base_s3_input_secret" {
  metadata {
    name      = "hmpps-knowledge-base-s3-input"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.hmpps_knowledge_base_s3_input.bucket_arn
    bucket_name = module.hmpps_knowledge_base_s3_input.bucket_name
  }
}

data "aws_iam_policy_document" "hmpps_knowledge_base_s3_input_to_equip_migration_queue" {
  statement {
    sid    = "AllowS3SendMessage"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions = [
      "sqs:SendMessage"
    ]

    resources = [
      module.equip_migration_queue.sqs_arn
    ]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"

      values = [
        module.hmpps_knowledge_base_s3_input.bucket_arn
      ]
    }
  }
}

resource "aws_sqs_queue_policy" "hmpps_knowledge_base_s3_input_to_equip_migration_queue_policy" {
  queue_url = module.equip_migration_queue.sqs_id
  policy    = data.aws_iam_policy_document.hmpps_knowledge_base_s3_input_to_equip_migration_queue.json
}

resource "aws_s3_bucket_notification" "hmpps_knowledge_base_s3_input_to_equip_migration_queue_notification" {
  bucket = module.hmpps_knowledge_base_s3_input.bucket_name

  queue {
    queue_arn = module.equip_migration_queue.sqs_arn
    events = [
      "s3:ObjectCreated:*"
    ]
  }

  depends_on = [
    aws_sqs_queue_policy.hmpps_knowledge_base_s3_input_to_equip_migration_queue_policy
  ]
}

module "hmpps_knowledge_base_s3_data_store" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.1"
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "hmpps_knowledge_base_s3_data_store_secret" {
  metadata {
    name      = "hmpps-knowledge-base-s3-data-store"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.hmpps_knowledge_base_s3_data_store.bucket_arn
    bucket_name = module.hmpps_knowledge_base_s3_data_store.bucket_name
  }
}

module "hmpps_knowledge_base_s3_archive" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.1"
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "hmpps_knowledge_base_s3_archive_secret" {
  metadata {
    name      = "hmpps-knowledge-base-s3-archive"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.hmpps_knowledge_base_s3_archive.bucket_arn
    bucket_name = module.hmpps_knowledge_base_s3_archive.bucket_name
  }
}
