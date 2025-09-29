module "hmpps_audit_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name                  = "hmpps_audit_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.hmpps_audit_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
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


module "hmpps_audit_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name        = "hmpps_audit_dlq"
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

resource "kubernetes_secret" "hmpps_audit_queue_secret" {
  metadata {
    name      = "sqs-audit-queue-secret"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.hmpps_audit_queue.sqs_id
    sqs_queue_arn  = module.hmpps_audit_queue.sqs_arn
    sqs_queue_name = module.hmpps_audit_queue.sqs_name
  }
}

resource "kubernetes_secret" "hmpps_audit_dead_letter_queue_secret" {
  metadata {
    name      = "sqs-audit-queue-dl-secret"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.hmpps_audit_dead_letter_queue.sqs_id
    sqs_queue_arn  = module.hmpps_audit_dead_letter_queue.sqs_arn
    sqs_queue_name = module.hmpps_audit_dead_letter_queue.sqs_name
  }
}


module "hmpps_prisoner_audit_queue" {

  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name                  = "hmpps_prisoner_audit_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.hmpps_prisoner_audit_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
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


module "hmpps_prisoner_audit_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name        = "hmpps_prisoner_audit_dlq"
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

resource "kubernetes_secret" "hmpps_prisoner_audit_queue_secret" {
  metadata {
    name      = "sqs-prisoner-audit-queue-secret"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.hmpps_prisoner_audit_queue.sqs_id
    sqs_queue_arn  = module.hmpps_prisoner_audit_queue.sqs_arn
    sqs_queue_name = module.hmpps_prisoner_audit_queue.sqs_name
  }
}

resource "kubernetes_secret" "hmpps_prisoner_audit_dead_letter_queue_secret" {
  metadata {
    name      = "sqs-prisoner-audit-queue-dl-secret"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.hmpps_prisoner_audit_dead_letter_queue.sqs_id
    sqs_queue_arn  = module.hmpps_prisoner_audit_dead_letter_queue.sqs_arn
    sqs_queue_name = module.hmpps_prisoner_audit_dead_letter_queue.sqs_name
  }
}

module "hmpps_audit_users_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name                  = "hmpps_audit_users_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.hmpps_audit_users_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
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


module "hmpps_audit_users_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name        = "hmpps_audit_users_dlq"
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

resource "kubernetes_secret" "hmpps_audit_users_queue_secret" {
  metadata {
    name      = "sqs-audit-users-queue-secret"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.hmpps_audit_users_queue.sqs_id
    sqs_queue_arn  = module.hmpps_audit_users_queue.sqs_arn
    sqs_queue_name = module.hmpps_audit_users_queue.sqs_name
  }
}

resource "kubernetes_secret" "hmpps_audit_users_dead_letter_queue_secret" {
  metadata {
    name      = "sqs-audit-users-queue-dl-secret"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.hmpps_audit_users_dead_letter_queue.sqs_id
    sqs_queue_arn  = module.hmpps_audit_users_dead_letter_queue.sqs_arn
    sqs_queue_name = module.hmpps_audit_users_dead_letter_queue.sqs_name
  }
}


# queue permissions for other services

resource "kubernetes_secret" "approved_prisoner_audit_client_arns" {
  metadata {
    name = "approved-prisoner-audit-client-arns"
    namespace = var.namespace
  }
}

data "kubernetes_secret" "approved_prisoner_audit_client_arns" {
  metadata {
    name      = kubernetes_secret.approved_prisoner_audit_client_arns.metadata[0].name
    namespace = var.namespace
  }
}

locals {
  # This will intentionally cause the pipeline to fail if the target secret does not contain the expects keys.
  prisoner_audit_client_arns = [for approved_client in var.approved_prisoner_audit_clients : data.kubernetes_secret.approved_prisoner_audit_client_arns.data[approved_client]]

  prisoner_audit_arns_with_manage_access = [module.hmpps-audit-api-irsa.role_arn]

  prisoner_audit_arns_with_send_access = concat(local.prisoner_audit_client_arns, local.prisoner_audit_arns_with_manage_access)
}


resource "aws_sqs_queue_policy" "hmpps_prisoner_audit_queue_policy" {
  queue_url = module.hmpps_prisoner_audit_queue.sqs_id

  policy = jsonencode({
    Version = "2012-10-17",
    Id      = "${module.hmpps_prisoner_audit_queue.sqs_arn}/SQSDefaultPolicy",
    Statement = [
      {
        Sid       = "DenyPrisonerAuditQueueManage",
        Effect    = "Deny",
        Principal = { AWS = "*" },
        Resource  = module.hmpps_prisoner_audit_queue.sqs_arn,
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:PurgeQueue",
          "sqs:ChangeMessageVisibility"
        ],
        Condition = {
          ArnNotEquals = {
            "aws:PrincipalArn" = local.prisoner_audit_arns_with_manage_access
          }
        }
      },
      {
        Sid       = "DenyPrisonerAuditQueueSend",
        Effect    = "Deny",
        Principal = { AWS = "*" },
        Resource  = module.hmpps_prisoner_audit_queue.sqs_arn,
        Action    = "sqs:SendMessage",
        Condition = {
          ArnNotEquals = {
            "aws:PrincipalArn" = local.prisoner_audit_arns_with_send_access
          }
        }
      },
      {
        Sid       = "AllowPrisonerAuditQueueSend",
        Effect    = "Allow",
        Principal = {
          AWS = local.prisoner_audit_arns_with_send_access
        },
        Resource = module.hmpps_prisoner_audit_queue.sqs_arn,
        Action   = "sqs:SendMessage"
      },
      {
        Sid       = "AllowPrisonerAuditQueueManage",
        Effect    = "Allow",
        Principal = {
          AWS = local.prisoner_audit_arns_with_manage_access
        },
        Resource  = module.hmpps_prisoner_audit_queue.sqs_arn,
        Action = "sqs:*"
      }
    ]
  })
}


