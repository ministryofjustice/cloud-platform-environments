module "ims_extractor_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.11.0"

  environment-name           = var.environment
  team_name                  = var.team_name
  infrastructure-support     = var.infrastructure_support
  application                = var.application
  sqs_name                   = "ims_extractor_queue_${var.environment}"
  encrypt_sqs_kms            = "true"
  message_retention_seconds  = 1209600
  visibility_timeout_seconds = 120
  namespace                  = var.namespace


  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.ims_extractor_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
  }

EOF

  providers = {
    aws = aws.london
  }
}

module "ims_extractor_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.11.0"

  environment-name       = var.environment
  team_name              = var.team_name
  infrastructure-support = var.infrastructure_support
  application            = var.application
  sqs_name               = "ims_extractor_dl_queue_${var.environment}"
  encrypt_sqs_kms        = "true"
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}


module "ims_transformer_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.11.0"

  environment-name           = var.environment
  team_name                  = var.team_name
  infrastructure-support     = var.infrastructure_support
  application                = var.application
  sqs_name                   = "ims_transformer_queue_${var.environment}"
  encrypt_sqs_kms            = "true"
  message_retention_seconds  = 1209600
  visibility_timeout_seconds = 120
  namespace                  = var.namespace


  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.ims_transformer_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
  }

EOF

  providers = {
    aws = aws.london
  }
}

module "ims_transformer_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.11.0"

  environment-name       = var.environment
  team_name              = var.team_name
  infrastructure-support = var.infrastructure_support
  application            = var.application
  sqs_name               = "ims_transformer_dl_queue_${var.environment}"
  encrypt_sqs_kms        = "true"
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "ims_extractor_queue" {
  metadata {
    name      = "ims-extractor-queue-output"
    namespace = var.namespace
  }

  data = {
    sqs_id            = module.ims_extractor_queue.sqs_id
    sqs_arn           = module.ims_extractor_queue.sqs_arn
    sqs_name          = module.ims_extractor_queue.sqs_name
  }
}

resource "kubernetes_secret" "ims_extractor_dead_letter_queue" {
  metadata {
    name      = "ims-extractor-dlq-output"
    namespace = var.namespace
  }

  data = {
    sqs_id            = module.ims_extractor_dead_letter_queue.sqs_id
    sqs_arn           = module.ims_extractor_dead_letter_queue.sqs_arn
    sqs_name          = module.ims_extractor_dead_letter_queue.sqs_name
  }
}

resource "kubernetes_secret" "ims_transformer_queue" {
  metadata {
    name      = "ims-transformer-queue-output"
    namespace = var.namespace
  }

  data = {
    sqs_id            = module.ims_transformer_queue.sqs_id
    sqs_arn           = module.ims_transformer_queue.sqs_arn
    sqs_name          = module.ims_trasnformer_queue.sqs_name
  }
}

resource "kubernetes_secret" "ims_transformer_dead_letter_queue" {
  metadata {
    name      = "ims-transformer-dlq-output"
    namespace = var.namespace
  }

  data = {
    sqs_id            = module.ims_transformer_dead_letter_queue.sqs_id
    sqs_arn           = module.ims_transformer_dead_letter_queue.sqs_arn
    sqs_name          = module.ims_transformer_dead_letter_queue.sqs_name
  }
}