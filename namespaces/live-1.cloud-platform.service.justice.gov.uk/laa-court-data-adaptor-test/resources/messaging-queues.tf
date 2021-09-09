data "aws_caller_identity" "current" {}

resource "random_id" "id" {
  byte_length = 6
}

data "aws_iam_policy_document" "laa_crime_apps" {
  statement {
    sid     = "PublishPolicy"
    effect  = "Allow"
    actions = ["sqs:SendMessage"]

    resources = [
      module.create_link_queue.sqs_arn,
      module.unlink_queue.sqs_arn,
      module.laa_status_update_queue.sqs_arn,
      module.hearing_resulted_queue.sqs_arn,
      module.prosecution_concluded_queue.sqs_arn,
    ]

    principals {
      type = "AWS"
      identifiers = ["*"]
    }
  }

  statement {
    sid     = "ConsumePolicy"
    effect  = "Allow"
    actions = ["sqs:ReceiveMessage"]

    resources = [
      module.create_link_queue.sqs_arn,
      module.unlink_queue.sqs_arn,
      module.laa_status_update_queue.sqs_arn,
      module.hearing_resulted_queue.sqs_arn,
      module.prosecution_concluded_queue.sqs_arn,
    ]

    principals {
      type = "AWS"
      identifiers = [data.aws_caller_identity.current.account_id]
    }
  }
}

resource "aws_iam_policy" "laa_crime_apps" {
  name   = "laa_crime_apps_policy"
  policy = data.aws_iam_policy_document.laa_crime_apps.json
}

resource "aws_iam_user" "laa_crime_apps" {
  name  = "cp-sqs-${random_id.id.hex}"
  path  = "/system/sqs-user/${var.team_name}/"
}

resource "aws_iam_access_key" "laa_crime_apps" {
  user = aws_iam_user.laa_crime_apps.name
}

resource "aws_iam_user_policy_attachment" "laa_crime_apps" {
  user       = aws_iam_user.laa_crime_apps.name
  policy_arn = aws_iam_policy.laa_crime_apps.arn
}

module "create_link_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.4"

  environment-name           = var.environment_name
  team_name                  = var.team_name
  infrastructure-support     = var.infrastructure_support
  application                = var.application
  sqs_name                   = "create-link-queue"
  encrypt_sqs_kms            = var.encrypt_sqs_kms
  message_retention_seconds  = var.message_retention_seconds
  namespace                  = var.namespace

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.create_link_queue_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
  }
  EOF

  providers = {
    aws = aws.london
  }
}

module "create_link_queue_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.4"

  environment-name       = var.environment_name
  team_name              = var.team_name
  infrastructure-support = var.infrastructure_support
  application            = var.application
  sqs_name               = "create-link-queue-dl"
  encrypt_sqs_kms        = var.encrypt_sqs_kms
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

module "unlink_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.4"

  environment-name           = var.environment_name
  team_name                  = var.team_name
  infrastructure-support     = var.infrastructure_support
  application                = var.application
  sqs_name                   = "unlink-queue"
  encrypt_sqs_kms            = var.encrypt_sqs_kms
  message_retention_seconds  = var.message_retention_seconds
  namespace                  = var.namespace

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.unlink_queue_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
  }
  EOF

  providers = {
    aws = aws.london
  }
}

module "unlink_queue_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.4"

  environment-name       = var.environment_name
  team_name              = var.team_name
  infrastructure-support = var.infrastructure_support
  application            = var.application
  sqs_name               = "unlink-queue-dl"
  encrypt_sqs_kms        = var.encrypt_sqs_kms
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

module "laa_status_update_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.4"

  environment-name          = var.environment_name
  team_name                 = var.team_name
  infrastructure-support    = var.infrastructure_support
  application               = var.application
  sqs_name                  = "laa-status-update-queue"
  encrypt_sqs_kms           = var.encrypt_sqs_kms
  message_retention_seconds = var.message_retention_seconds
  namespace                 = var.namespace

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.laa_status_update_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
  }
  EOF

  providers = {
    aws = aws.london
  }
}

module "laa_status_update_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.4"

  environment-name       = var.environment_name
  team_name              = var.team_name
  infrastructure-support = var.infrastructure_support
  application            = var.application
  sqs_name               = "laa-status-update-queue-dl"
  encrypt_sqs_kms        = var.encrypt_sqs_kms
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

module "hearing_resulted_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.4"

  environment-name           = var.environment_name
  team_name                  = var.team_name
  infrastructure-support     = var.infrastructure_support
  application                = var.application
  sqs_name                   = "hearing-resulted-queue"
  encrypt_sqs_kms            = var.encrypt_sqs_kms
  message_retention_seconds  = var.message_retention_seconds
  namespace                  = var.namespace

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.hearing_resulted_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
  }
  EOF

  providers = {
    aws = aws.london
  }
}

module "hearing_resulted_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.4"

  environment-name       = var.environment_name
  team_name              = var.team_name
  infrastructure-support = var.infrastructure_support
  application            = var.application
  sqs_name               = "hearing-resulted-queue-dl"
  encrypt_sqs_kms        = var.encrypt_sqs_kms
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

module "prosecution_concluded_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.4"

  environment-name          = var.environment_name
  team_name                 = var.team_name
  infrastructure-support    = var.infrastructure_support
  application               = var.application
  sqs_name                  = "prosecution-concluded-queue"
  encrypt_sqs_kms           = var.encrypt_sqs_kms
  message_retention_seconds = var.message_retention_seconds
  namespace                 = var.namespace

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.prosecution_concluded_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
  }
  EOF

  providers = {
    aws = aws.london
  }
}

module "prosecution_concluded_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.4"

  environment-name       = var.environment_name
  team_name              = var.team_name
  infrastructure-support = var.infrastructure_support
  application            = var.application
  sqs_name               = "prosecution-concluded-queue-dl"
  encrypt_sqs_kms        = var.encrypt_sqs_kms
  namespace              = var.namespace

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
    access_key_id                    = aws_iam_access_key.laa_crime_apps.id
    secret_access_key                = aws_iam_access_key.laa_crime_apps.secret
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
    sqs_url_d_prosecution_concluded  = module.prosecution_concluded_dead_letter_queue.sqs_id
    sqs_arn_d_prosecution_concluded  = module.prosecution_concluded_dead_letter_queue.sqs_arn
    sqs_name_d_prosecution_concluded = module.prosecution_concluded_dead_letter_queue.sqs_name
  }
}
