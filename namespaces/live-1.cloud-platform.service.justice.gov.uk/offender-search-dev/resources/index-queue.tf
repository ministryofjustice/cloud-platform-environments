module "probation_offender_index_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.0"

  environment-name          = var.environment-name
  team_name                 = var.team_name
  infrastructure-support    = var.infrastructure-support
  application               = var.application
  sqs_name                  = "probation_offender_search_index_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.probation_offender_index_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
  }
  
EOF

  providers = {
    aws = aws.london
  }
}

resource "aws_sqs_queue_policy" "probation_offender_index_queue_policy" {
  queue_url = module.probation_offender_index_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.probation_offender_index_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.probation_offender_index_queue.sqs_arn}",
          "Action": "SQS:SendMessage"
        }
      ]
  }

EOF

}

module "probation_offender_index_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.0"

  environment-name       = var.environment-name
  team_name              = var.team_name
  infrastructure-support = var.infrastructure-support
  application            = var.application
  sqs_name               = "probation_offender_search_index_dl_queue"
  encrypt_sqs_kms        = "true"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "probation_offender_index_queue" {
  metadata {
    name      = "poi-idx-sqs-instance-output"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.probation_offender_index_queue.access_key_id
    secret_access_key = module.probation_offender_index_queue.secret_access_key
    sqs_id            = module.probation_offender_index_queue.sqs_id
    sqs_arn           = module.probation_offender_index_queue.sqs_arn
    sqs_name          = module.probation_offender_index_queue.sqs_name
  }
}

resource "kubernetes_secret" "probation_offender_index_dead_letter_queue" {
  metadata {
    name      = "poi-idx-sqs-dl-instance-output"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.probation_offender_index_dead_letter_queue.access_key_id
    secret_access_key = module.probation_offender_index_dead_letter_queue.secret_access_key
    sqs_id            = module.probation_offender_index_dead_letter_queue.sqs_id
    sqs_arn           = module.probation_offender_index_dead_letter_queue.sqs_arn
    sqs_name          = module.probation_offender_index_dead_letter_queue.sqs_name
  }
}
