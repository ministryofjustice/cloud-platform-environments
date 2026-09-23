module "create_link_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name                   = "create-link-queue"
  encrypt_sqs_kms            = var.encrypt_sqs_kms
  message_retention_seconds  = var.message_retention_seconds
  visibility_timeout_seconds = var.visibility_timeout_seconds

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.create_link_queue_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
  }
  EOF

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  # TODO: Switch this to var.team_name when we are ready to switch repo
  team_name              = "crime-apps"
  namespace              = var.namespace
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

module "create_link_queue_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name        = "create-link-queue-dl"
  encrypt_sqs_kms = var.encrypt_sqs_kms

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  # TODO: Switch this to var.team_name when we are ready to switch the queue
  team_name = "crime-apps"
  namespace              = var.namespace
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

module "unlink_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name                   = "unlink-queue"
  encrypt_sqs_kms            = var.encrypt_sqs_kms
  message_retention_seconds  = var.message_retention_seconds
  visibility_timeout_seconds = var.visibility_timeout_seconds

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.unlink_queue_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
  }
  EOF

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  # TODO: Switch this to var.team_name when we are ready to switch the queue
  team_name = "crime-apps"
  namespace              = var.namespace
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

module "unlink_queue_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name        = "unlink-queue-dl"
  encrypt_sqs_kms = var.encrypt_sqs_kms

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  # TODO: Switch this to var.team_name when we are ready to switch the queue
  team_name = "crime-apps"
  namespace              = var.namespace
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

module "hearing_resulted_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name                   = "hearing-resulted-queue"
  encrypt_sqs_kms            = var.encrypt_sqs_kms
  message_retention_seconds  = var.message_retention_seconds
  visibility_timeout_seconds = var.visibility_timeout_seconds

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.hearing_resulted_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
  }
  EOF

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  # TODO: Switch this to var.team_name when we are ready to switch the queue
  team_name = "crime-apps"
  namespace              = var.namespace
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

module "hearing_resulted_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name        = "hearing-resulted-queue-dl"
  encrypt_sqs_kms = var.encrypt_sqs_kms

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  # TODO: Switch this to var.team_name when we are ready to switch the queue
  team_name = "crime-apps"
  namespace              = var.namespace
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

module "prosecution_concluded_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name                   = "prosecution-concluded-queue"
  encrypt_sqs_kms            = var.encrypt_sqs_kms
  message_retention_seconds  = var.message_retention_seconds
  delay_seconds              = "120"
  visibility_timeout_seconds = var.visibility_timeout_seconds

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.prosecution_concluded_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
  }
  EOF

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  # TODO: Switch this to var.team_name when we are ready to switch the queue
  team_name = "crime-apps"
  namespace              = var.namespace
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

module "prosecution_concluded_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name        = "prosecution-concluded-queue-dl"
  encrypt_sqs_kms = var.encrypt_sqs_kms

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  # TODO: Switch this to var.team_name when we are ready to switch the queue
  team_name = "crime-apps"
  namespace              = var.namespace
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "create_link_queue" {
  metadata {
    name      = "cda-messaging-queues-output"
    namespace = var.namespace
  }

  data = {
    sqs_url_link                     = module.create_link_queue.sqs_id
    sqs_arn_link                     = module.create_link_queue.sqs_arn
    sqs_name_link                    = module.create_link_queue.sqs_name
    sqs_url_d_link                   = module.create_link_queue_dead_letter_queue.sqs_id
    sqs_arn_d_link                   = module.create_link_queue_dead_letter_queue.sqs_arn
    sqs_name_d_link                  = module.create_link_queue_dead_letter_queue.sqs_name
    sqs_url_unlink                   = module.unlink_queue.sqs_id
    sqs_arn_unlink                   = module.unlink_queue.sqs_arn
    sqs_name_unlink                  = module.unlink_queue.sqs_name
    sqs_url_d_unlink                 = module.unlink_queue_dead_letter_queue.sqs_id
    sqs_arn_d_unlink                 = module.unlink_queue_dead_letter_queue.sqs_arn
    sqs_name_d_unlink                = module.unlink_queue_dead_letter_queue.sqs_name
    sqs_url_hearing_resulted         = module.hearing_resulted_queue.sqs_id
    sqs_arn_hearing_resulted         = module.hearing_resulted_queue.sqs_arn
    sqs_name_hearing_resulted        = module.hearing_resulted_queue.sqs_name
    sqs_url_d_hearing_resulted       = module.hearing_resulted_dead_letter_queue.sqs_id
    sqs_arn_d_hearing_resulted       = module.hearing_resulted_dead_letter_queue.sqs_arn
    sqs_name_d_hearing_resulted      = module.hearing_resulted_dead_letter_queue.sqs_name
    sqs_url_prosecution_concluded    = module.prosecution_concluded_queue.sqs_id
    sqs_arn_prosecution_concluded    = module.prosecution_concluded_queue.sqs_arn
    sqs_name_prosecution_concluded   = module.prosecution_concluded_queue.sqs_name
    sqs_url_d_prosecution_concluded  = module.prosecution_concluded_dead_letter_queue.sqs_id
    sqs_arn_d_prosecution_concluded  = module.prosecution_concluded_dead_letter_queue.sqs_arn
    sqs_name_d_prosecution_concluded = module.prosecution_concluded_dead_letter_queue.sqs_name
  }
}

resource "kubernetes_secret" "sqs_queue_irsa_policy_arn" {
  metadata {
    name      = "sqs-queue-irsa-policy-arn"
    namespace = var.namespace
  }

  data = {
    hearing_resulted_queue_irsa_policy_arn      = module.hearing_resulted_queue.irsa_policy_arn
    prosecution_concluded_queue_irsa_policy_arn = module.prosecution_concluded_queue.irsa_policy_arn
    create_link_queue_irsa_policy_arn           = module.create_link_queue.irsa_policy_arn
    unlink_queue_irsa_policy_arn                = module.unlink_queue.irsa_policy_arn
  }
}
