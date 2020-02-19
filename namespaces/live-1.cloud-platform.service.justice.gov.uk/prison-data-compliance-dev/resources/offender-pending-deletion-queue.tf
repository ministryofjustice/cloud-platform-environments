module "off_pend_del_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.0"

  environment-name           = var.environment-name
  team_name                  = var.team_name
  infrastructure-support     = var.infrastructure-support
  application                = var.application
  sqs_name                   = "off_pend_del_queue"
  encrypt_sqs_kms            = "true"
  visibility_timeout_seconds = 300
  message_retention_seconds  = 1209600

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.offender_pending_deletion_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
  }
  EOF

  providers = {
    aws = aws.london
  }
}

resource "aws_sqs_queue_policy" "off_pend_del_queue_policy" {
  queue_url = module.off_pend_del_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.off_pend_del_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Sid": "PublishPolicy",
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.off_pend_del_queue.sqs_arn}",
          "Action": "sqs:SendMessage"
        },
        {
          "Sid": "ConsumePolicy",
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.off_pend_del_queue.sqs_arn}",
          "Action": "sqs:ReceiveMessage"
        }
      ]
  }
   EOF
}

module "offender_pending_deletion_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.0"

  environment-name       = var.environment-name
  team_name              = var.team_name
  infrastructure-support = var.infrastructure-support
  application            = var.application
  sqs_name               = "off_pend_del_queue_dl"
  encrypt_sqs_kms        = "true"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "off_pend_del_queue" {
  metadata {
    name      = "offender-pending-deletion-sqs-instance-output"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.off_pend_del_queue.access_key_id
    secret_access_key = module.off_pend_del_queue.secret_access_key
    sqs_ocne_url      = module.off_pend_del_queue.sqs_id
    sqs_ocne_arn      = module.off_pend_del_queue.sqs_arn
    sqs_ocne_name     = module.off_pend_del_queue.sqs_name
  }
}

resource "kubernetes_secret" "offender_pending_deletion_dead_letter_queue" {
  metadata {
    name      = "offender-pending-deletion-sqs-dl-instance-output"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.offender_pending_deletion_dead_letter_queue.access_key_id
    secret_access_key = module.offender_pending_deletion_dead_letter_queue.secret_access_key
    sqs_ocne_url      = module.offender_pending_deletion_dead_letter_queue.sqs_id
    sqs_ocne_arn      = module.offender_pending_deletion_dead_letter_queue.sqs_arn
    sqs_ocne_name     = module.offender_pending_deletion_dead_letter_queue.sqs_name
  }
}
