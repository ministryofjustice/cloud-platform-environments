module "create_link_queue_m" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name                   = "create-link-queue-m"
  encrypt_sqs_kms            = var.encrypt_sqs_kms
  message_retention_seconds  = var.message_retention_seconds
  visibility_timeout_seconds = var.visibility_timeout_seconds

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.create_link_queue_m_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
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

  providers = {
    aws = aws.london
  }
}


resource "aws_sqs_queue_policy" "create_link_queue_m_policy" {
  queue_url = module.create_link_queue_m.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.create_link_queue_m.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Sid": "ConsumePolicy",
          "Effect": "Allow",
          "Principal": {
          "AWS": [
            "arn:aws:iam::411213865113:role/LAA-maat-cd-api-development-ECSTaskExecutionRole-14XJSFYJHCVF0"
              ]
          },
          "Resource": "${module.create_link_queue_m.sqs_arn}",
          "Action": "sqs:*"
        }
      ]
  }
   EOF
}

module "create_link_queue_m_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name        = "create-link-queue-dl-m"
  encrypt_sqs_kms = var.encrypt_sqs_kms

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

module "unlink_queue_m" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name                   = "unlink-queue-m"
  encrypt_sqs_kms            = var.encrypt_sqs_kms
  message_retention_seconds  = var.message_retention_seconds
  visibility_timeout_seconds = var.visibility_timeout_seconds

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.unlink_queue_m_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
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

  providers = {
    aws = aws.london
  }
}

resource "aws_sqs_queue_policy" "unlink_queue_m_policy" {
  queue_url = module.unlink_queue_m.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.unlink_queue_m.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Sid": "ConsumePolicy",
          "Effect": "Allow",
          "Principal": {
          "AWS": [
            "arn:aws:iam::411213865113:role/LAA-maat-cd-api-development-ECSTaskExecutionRole-14XJSFYJHCVF0"
              ]
          },
          "Resource": "${module.unlink_queue_m.sqs_arn}",
          "Action": "sqs:*"
        }
      ]
  }
   EOF
}

module "unlink_queue_m_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name        = "unlink-queue-dl-m"
  encrypt_sqs_kms = var.encrypt_sqs_kms

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

module "hearing_resulted_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

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
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

module "laa_status_update_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name                  = "laa-status-update-queue"
  encrypt_sqs_kms           = var.encrypt_sqs_kms
  message_retention_seconds = var.message_retention_seconds

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.laa_status_update_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
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

  providers = {
    aws = aws.london
  }
}

resource "aws_sqs_queue_policy" "laa_status_update_queue_policy" {
  queue_url = module.laa_status_update_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.laa_status_update_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Sid": "ConsumePolicy",
          "Effect": "Allow",
          "Principal": {
          "AWS": [
            "arn:aws:iam::411213865113:role/LAA-maat-cd-api-development-ECSTaskExecutionRole-14XJSFYJHCVF0"
              ]
          },
          "Resource": "${module.laa_status_update_queue.sqs_arn}",
          "Action": "sqs:*"
        }
      ]
  }
   EOF
}

module "laa_status_update_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name        = "laa-status-update-queue-dl"
  encrypt_sqs_kms = var.encrypt_sqs_kms

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

resource "aws_sqs_queue_policy" "hearing_resulted_queue_policy" {
  queue_url = module.hearing_resulted_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.hearing_resulted_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Sid": "ConsumePolicy",
          "Effect": "Allow",
          "Principal": {
          "AWS": [
            "arn:aws:iam::411213865113:role/LAA-maat-cd-api-development-ECSTaskExecutionRole-14XJSFYJHCVF0"
              ]
          },
          "Resource": "${module.hearing_resulted_queue.sqs_arn}",
          "Action": "sqs:*"
        }
      ]
  }
   EOF
}

module "hearing_resulted_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name        = "hearing-resulted-queue-dl"
  encrypt_sqs_kms = var.encrypt_sqs_kms

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

module "prosecution_concluded_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name                   = "prosecution-concluded-queue"
  encrypt_sqs_kms            = var.encrypt_sqs_kms
  message_retention_seconds  = var.message_retention_seconds
  visibility_timeout_seconds = var.visibility_timeout_seconds

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.prosecution_concluded_dl_queue.sqs_arn}","maxReceiveCount": 3
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

  providers = {
    aws = aws.london
  }
}

module "prosecution_concluded_dl_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name        = "prosecution-concluded-queue-dl"
  encrypt_sqs_kms = var.encrypt_sqs_kms

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

resource "aws_sqs_queue_policy" "prosecution_concluded_queue_policy" {
  queue_url = module.prosecution_concluded_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.prosecution_concluded_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Sid": "ConsumePolicy",
          "Effect": "Allow",
          "Principal": {
          "AWS": [
            "arn:aws:iam::411213865113:role/LAA-maat-cd-api-development-ECSTaskExecutionRole-14XJSFYJHCVF0"
              ]
          },
          "Resource": "${module.prosecution_concluded_queue.sqs_arn}",
          "Action": "sqs:*"
        }
      ]
  }
   EOF
}

resource "kubernetes_secret" "create_link_queue_m" {
  metadata {
    name      = "cda-messaging-queues-output"
    namespace = var.namespace
  }

  data = {
    sqs_url_link                     = module.create_link_queue_m.sqs_id
    sqs_arn_link                     = module.create_link_queue_m.sqs_arn
    sqs_name_link                    = module.create_link_queue_m.sqs_name
    sqs_url_d_link                   = module.create_link_queue_m_dead_letter_queue.sqs_id
    sqs_arn_d_link                   = module.create_link_queue_m_dead_letter_queue.sqs_arn
    sqs_name_d_link                  = module.create_link_queue_m_dead_letter_queue.sqs_name
    sqs_url_unlink                   = module.unlink_queue_m.sqs_id
    sqs_arn_unlink                   = module.unlink_queue_m.sqs_arn
    sqs_name_unlink                  = module.unlink_queue_m.sqs_name
    sqs_url_d_unlink                 = module.unlink_queue_m_dead_letter_queue.sqs_id
    sqs_arn_d_unlink                 = module.unlink_queue_m_dead_letter_queue.sqs_arn
    sqs_name_d_unlink                = module.unlink_queue_m_dead_letter_queue.sqs_name
    sqs_url_laa_status               = module.laa_status_update_queue.sqs_id
    sqs_arn_laa_status               = module.laa_status_update_queue.sqs_arn
    sqs_name_laa_status              = module.laa_status_update_queue.sqs_name
    sqs_url_d_laa_status             = module.laa_status_update_dead_letter_queue.sqs_id
    sqs_arn_d_laa_status             = module.laa_status_update_dead_letter_queue.sqs_arn
    sqs_name_d_laa_status            = module.laa_status_update_dead_letter_queue.sqs_name
    sqs_url_hearing_resulted         = module.hearing_resulted_queue.sqs_id
    sqs_arn_hearing_resulted         = module.hearing_resulted_queue.sqs_arn
    sqs_name_hearing_resulted        = module.hearing_resulted_queue.sqs_name
    sqs_url_d_hearing_resulted       = module.hearing_resulted_dead_letter_queue.sqs_id
    sqs_arn_d_hearing_resulted       = module.hearing_resulted_dead_letter_queue.sqs_arn
    sqs_name_d_hearing_resulted      = module.hearing_resulted_dead_letter_queue.sqs_name
    sqs_url_prosecution_concluded    = module.prosecution_concluded_queue.sqs_id
    sqs_arn_prosecution_concluded    = module.prosecution_concluded_queue.sqs_arn
    sqs_name_prosecution_concluded   = module.prosecution_concluded_queue.sqs_name
    sqs_url_d_prosecution_concluded  = module.prosecution_concluded_dl_queue.sqs_id
    sqs_arn_d_prosecution_concluded  = module.prosecution_concluded_dl_queue.sqs_arn
    sqs_name_d_prosecution_concluded = module.prosecution_concluded_dl_queue.sqs_name
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
    create_link_queue_m_irsa_policy_arn         = module.create_link_queue_m.irsa_policy_arn
    unlink_queue_m_irsa_policy_arn              = module.unlink_queue_m.irsa_policy_arn
  }
}
