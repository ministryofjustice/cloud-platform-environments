# ----- SQS request queues -----
module "ims_ai_request_queue" {
  
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name                   = "ims_ai_request_queue"
  encrypt_sqs_kms            = "true"
  message_retention_seconds  = 1209600
  visibility_timeout_seconds = 120

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.ims_ai_request_dlq.sqs_arn}","maxReceiveCount": 3
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

module "ims_ai_request_dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name        = "ims_ai_request_dl_queue"
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

resource "kubernetes_secret" "ims_ai_request_queue" {
  metadata {
    name      = "ims-ai-request-queue-instance-output"
    namespace = var.namespace
  }

  data = {
    sqs_url  = module.ims_ai_request_queue.sqs_id
    sqs_arn  = module.ims_ai_request_queue.sqs_arn
    sqs_name = module.ims_ai_request_queue.sqs_name
  }
}

resource "kubernetes_secret" "ims_ai_request_dlq" {
  metadata {
    name      = "ims-ai-request-dlq-instance-output"
    namespace = var.namespace
  }

  data = {
    sqs_url  = module.ims_ai_request_dlq.sqs_id
    sqs_arn  = module.ims_ai_request_dlq.sqs_arn
    sqs_name = module.ims_ai_request_dlq.sqs_name
  }
}

# ----- SQS response queues -----
module "ims_ai_response_queue" {

  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name                   = "ims_ai_response_queue"
  encrypt_sqs_kms            = "true"
  message_retention_seconds  = 1209600
  visibility_timeout_seconds = 120

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.ims_ai_response_dlq.sqs_arn}","maxReceiveCount": 3
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

module "ims_ai_response_dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name        = "ims_ai_response_dl_queue"
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

resource "kubernetes_secret" "ims_ai_response_queue" {
  metadata {
    name      = "ims-ai-response-queue-instance-output"
    namespace = var.namespace
  }

  data = {
    sqs_url  = module.ims_ai_response_queue.sqs_id
    sqs_arn  = module.ims_ai_response_queue.sqs_arn
    sqs_name = module.ims_ai_response_queue.sqs_name
  }
}

resource "kubernetes_secret" "ims_ai_response_dlq" {
  metadata {
    name      = "ims-ai-response-dlq-instance-output"
    namespace = var.namespace
  }

  data = {
    sqs_url  = module.ims_ai_response_dlq.sqs_id
    sqs_arn  = module.ims_ai_response_dlq.sqs_arn
    sqs_name = module.ims_ai_response_dlq.sqs_name
  }
}

# ----- S3 Buckets -----
module "ims_ai_bucket" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.0"
  team_name              = var.team_name
  acl                    = "private"
  versioning             = false
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "ims_ai_bucket" {
  metadata {
    name      = "ims-ai-bucket-output"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.ims_ai_bucket.bucket_arn
    bucket_name = module.ims_ai_bucket.bucket_name
  }
}