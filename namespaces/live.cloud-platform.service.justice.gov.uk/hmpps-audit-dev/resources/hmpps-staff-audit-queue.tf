locals {
  staff_audit_client_arns = [for approved_client in var.approved_staff_audit_clients : data.kubernetes_secret.approved_staff_audit_client_arns.data[approved_client]]

  staff_audit_arns_with_manage_access = [module.hmpps-audit-api-irsa.role_arn]

  staff_audit_arns_with_send_access = concat(local.staff_audit_client_arns, local.staff_audit_arns_with_manage_access)

  # This is the list of namespaces the audit queue secret should be injected into
  staff_audit_namespaces = toset([
    "hmpps-audit-dev",
    "hmpps-prisoner-profile-dev",
  ])
}

module "hmpps_staff_audit_queue" {

  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name                  = "hmpps_staff_audit_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.hmpps_staff_audit_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
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


module "hmpps_staff_audit_dead_letter_queue" {
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

# This will inject the audit queue secret into all required namespaces.
resource "kubernetes_secret" "hmpps_staff_audit_queue_secret" {
  for_each = local.staff_audit_namespaces
  metadata {
    name      = "sqs-staff-audit-queue-secret"
    namespace = each.value
  }

  data = {
    sqs_queue_url  = module.hmpps_staff_audit_queue.sqs_id
    sqs_queue_arn  = module.hmpps_staff_audit_queue.sqs_arn
    sqs_queue_name = module.hmpps_staff_audit_queue.sqs_name
  }
}

resource "kubernetes_secret" "hmpps_staff_audit_dead_letter_queue_secret" {
  metadata {
    name      = "sqs-staff-audit-queue-dl-secret"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.hmpps_staff_audit_dead_letter_queue.sqs_id
    sqs_queue_arn  = module.hmpps_staff_audit_dead_letter_queue.sqs_arn
    sqs_queue_name = module.hmpps_staff_audit_dead_letter_queue.sqs_name
  }
}

# queue permissions for other services
# the approved_staff_audit_client_arns is generated in terraform however it must be populated
# manually using kubectl.
resource "kubernetes_secret" "approved_staff_audit_client_arns" {
  metadata {
    name = "approved-staff-audit-client-arns"
    namespace = var.namespace
  }
}

# This will read the current contents of the approved_staff_audit_client_arns secret.
data "kubernetes_secret" "approved_staff_audit_client_arns" {
  metadata {
    name      = kubernetes_secret.approved_staff_audit_client_arns.metadata[0].name
    namespace = var.namespace
  }
}

data "aws_iam_policy_document" "hmpps_staff_audit_queue_policy" {
  version   = "2012-10-17"
  policy_id = "${module.hmpps_staff_audit_queue.sqs_arn}/SQSDefaultPolicy"

  # Deny manage actions to everyone except the listed principals
  statement {
    sid    = "DenyPrisonerAuditQueueManage"
    effect = "Deny"

    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:PurgeQueue",
      "sqs:ChangeMessageVisibility",
    ]

    resources = [module.hmpps_staff_audit_queue.sqs_arn]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "ArnNotEquals"
      variable = "aws:PrincipalArn"
      values   = local.staff_audit_arns_with_manage_access
    }
  }

  # Deny send to everyone except the listed principals
  statement {
    sid    = "DenyPrisonerAuditQueueSend"
    effect = "Deny"

    actions   = ["sqs:SendMessage"]
    resources = [module.hmpps_staff_audit_queue.sqs_arn]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "ArnNotEquals"
      variable = "aws:PrincipalArn"
      values   = local.staff_audit_arns_with_send_access
    }
  }

  # Allow send to the permitted principals
  statement {
    sid    = "AllowPrisonerAuditQueueSend"
    effect = "Allow"

    actions   = ["sqs:SendMessage"]
    resources = [module.hmpps_staff_audit_queue.sqs_arn]

    principals {
      type        = "AWS"
      identifiers = local.staff_audit_arns_with_send_access
    }
  }

  # Allow full manage to the permitted principals
  statement {
    sid    = "AllowPrisonerAuditQueueManage"
    effect = "Allow"

    actions   = ["sqs:*"]
    resources = [module.hmpps_staff_audit_queue.sqs_arn]

    principals {
      type        = "AWS"
      identifiers = local.staff_audit_arns_with_manage_access
    }
  }
}

resource "aws_sqs_queue_policy" "hmpps_staff_audit_queue_policy" {
  queue_url = module.hmpps_staff_audit_queue.sqs_id
  policy    = data.aws_iam_policy_document.hmpps_staff_audit_queue_policy.json
}


