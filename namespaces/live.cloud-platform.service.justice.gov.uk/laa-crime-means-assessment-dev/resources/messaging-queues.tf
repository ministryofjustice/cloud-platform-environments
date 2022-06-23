module "means_assessment_post_processing_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.5"

  environment-name           = var.environment_name
  team_name                  = var.team_name
  infrastructure-support     = var.infrastructure_support
  application                = var.application
  sqs_name                   = "means_assessment_post_processing_queue"
  encrypt_sqs_kms            = var.encrypt_sqs_kms
  message_retention_seconds  = var.message_retention_seconds
  namespace                  = var.namespace
  visibility_timeout_seconds = var.visibility_timeout_seconds

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.means_assessment_post_processing_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
  }
  EOF

  providers = {
    aws = aws.london
  }
}

resource "aws_sqs_queue_policy" "means_assessment_post_processing_queue_policy" {
  queue_url = module.means_assessment_post_processing_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.means_assessment_post_processing_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Sid": "PublishPolicy",
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.means_assessment_post_processing_queue.sqs_arn}",
          "Action": "sqs:SendMessage"
        },
        {
          "Sid": "ConsumePolicy",
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.means_assessment_post_processing_queue.sqs_arn}",
          "Action": "sqs:ReceiveMessage"
        }
      ]
  }
   EOF
}

module "means_assessment_post_processing_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.5"

  environment-name       = var.environment_name
  team_name              = var.team_name
  infrastructure-support = var.infrastructure_support
  application            = var.application
  sqs_name               = "means-assessment-post-processing-queue-dl"
  existing_user_name     = module.means_assessment_post_processing_queue.user_name
  encrypt_sqs_kms        = var.encrypt_sqs_kms
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}


resource "kubernetes_secret" "create_link_queue_m" {
  metadata {
    name      = "cma-messaging-queues-output"
    namespace = var.namespace
  }

  data = {
    access_key_id                               = module.means_assessment_post_processing_queue.access_key_id
    secret_access_key                           = module.means_assessment_post_processing_queue.secret_access_key
    sqs_url_means_assessment_post_processing    = module.means_assessment_post_processing_queue.sqs_id
    sqs_arn_means_assessment_post_processing    = module.means_assessment_post_processing_queue.sqs_arn
    sqs_name_means_assessment_post_processing   = module.means_assessment_post_processing_queue.sqs_name
    sqs_url_d_means_assessment_post_processing  = module.means_assessment_post_processing_dead_letter_queue.sqs_id
    sqs_arn_d_means_assessment_post_processing  = module.means_assessment_post_processing_dead_letter_queue.sqs_arn
    sqs_name_d_means_assessment_post_processing = module.means_assessment_post_processing_dead_letter_queue.sqs_name

  }
}



