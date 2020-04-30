module "prisoner_offender_index_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.0"

  environment-name          = var.environment-name
  team_name                 = var.team_name
  infrastructure-support    = var.infrastructure-support
  application               = var.application
  sqs_name                  = "prisoner_offender_index_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.prisoner_offender_index_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
  }
  
EOF

  providers = {
    aws = aws.london
  }
}

resource "aws_sqs_queue_policy" "risk_profiler_change_policy" {
  queue_url = module.prisoner_offender_index_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.prisoner_offender_index_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.prisoner_offender_index_queue.sqs_arn}",
          "Action": "SQS:SendMessage"
        }
      ]
  }

EOF

}

module "prisoner_offender_index_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.0"

  environment-name       = var.environment-name
  team_name              = var.team_name
  infrastructure-support = var.infrastructure-support
  application            = var.application
  sqs_name               = "prisoner_offender_index_queue_dl"
  encrypt_sqs_kms        = "true"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "prisoner_offender_index_queue" {
  metadata {
    name      = "pos-idx-sqs-instance-output"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.prisoner_offender_index_queue.access_key_id
    secret_access_key = module.prisoner_offender_index_queue.secret_access_key
    sqs_pos_url       = module.prisoner_offender_index_queue.sqs_id
    sqs_pos_arn       = module.prisoner_offender_index_queue.sqs_arn
    sqs_pos_name      = module.prisoner_offender_index_queue.sqs_name
  }
}

resource "kubernetes_secret" "prisoner_offender_index_dead_letter_queue" {
  metadata {
    name      = "pos-idx-sqs-dl-instance-output"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.prisoner_offender_index_dead_letter_queue.access_key_id
    secret_access_key = module.prisoner_offender_index_dead_letter_queue.secret_access_key
    sqs_pos_url       = module.prisoner_offender_index_dead_letter_queue.sqs_id
    sqs_pos_arn       = module.prisoner_offender_index_dead_letter_queue.sqs_arn
    sqs_pos_name      = module.prisoner_offender_index_dead_letter_queue.sqs_name
  }
}


