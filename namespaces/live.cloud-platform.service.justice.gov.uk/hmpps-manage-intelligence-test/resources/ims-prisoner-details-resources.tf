module "ims_prisoner_details_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name                   = "ims_prisoner_details_queue"
  encrypt_sqs_kms            = "true"
  message_retention_seconds  = 1209600
  visibility_timeout_seconds = 120

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.ims_prisoner_details_dlq.sqs_arn}","maxReceiveCount": 3
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

resource "kubernetes_secret" "ims_prisoner_details_queue" {
  metadata {
    name      = "ims-prisoner-details-queue-instance-output"
    namespace = var.namespace
  }

  data = {
    sqs_id   = module.ims_prisoner_details_queue.sqs_id
    sqs_arn  = module.ims_prisoner_details_queue.sqs_arn
    sqs_name = module.ims_prisoner_details_queue.sqs_name
  }
}

module "ims_prisoner_details_dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name        = "ims_prisoner_details_dlq"
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

resource "kubernetes_secret" "ims_prisoner_details_dlq" {
  metadata {
    name      = "ims-prisoner-details-dlq-instance-output"
    namespace = var.namespace
  }

  data = {
    sqs_id   = module.ims_prisoner_details_dlq.sqs_id
    sqs_arn  = module.ims_prisoner_details_dlq.sqs_arn
    sqs_name = module.ims_prisoner_details_dlq.sqs_name
  }
}

module "ims_prisoner_details_bucket" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.0"
  team_name              = var.team_name
  acl                    = "private"
  versioning             = false
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

resource "kubernetes_secret" "ims_prisoner_details_bucket" {
  metadata {
    name      = "ims-prisoner-details-bucket-output"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.ims_prisoner_details_bucket.bucket_arn
    bucket_name = module.ims_prisoner_details_bucket.bucket_name
  }
}