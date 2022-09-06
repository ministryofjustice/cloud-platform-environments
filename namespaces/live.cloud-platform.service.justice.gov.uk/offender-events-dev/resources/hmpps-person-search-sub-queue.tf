module "person_search_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.8"

  environment-name          = var.environment-name
  team_name                 = var.team_name
  infrastructure-support    = var.infrastructure-support
  application               = var.application
  sqs_name                  = "person_search_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600
  namespace                 = var.namespace
  delay_seconds             = 2
  receive_wait_time_seconds = 20

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.person_search_dead_letter_queue.sqs_arn}","maxReceiveCount": 5
  }

EOF


  providers = {
    aws = aws.london
  }
}

resource "aws_sqs_queue_policy" "person_search_queue_policy" {
  queue_url = module.person_search_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.person_search_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.person_search_queue.sqs_arn}",
          "Action": "SQS:SendMessage",
          "Condition":
                      {
                        "ArnEquals":
                          {
                            "aws:SourceArn": ["${module.probation_offender_events.topic_arn}"]
                          }
                        }
        }
      ]
  }

EOF

}

module "person_search_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.8"

  environment-name       = var.environment-name
  team_name              = var.team_name
  infrastructure-support = var.infrastructure-support
  application            = var.application
  sqs_name               = "person_search_queue_dl"
  encrypt_sqs_kms        = "true"
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "person_search_queue" {
  metadata {
    name      = "person-search-sqs-instance-output"
    namespace = "hmpps-probation-search-dev"
  }

  data = {
    access_key_id     = module.person_search_queue.access_key_id
    secret_access_key = module.person_search_queue.secret_access_key
    sqs_queue_url     = module.person_search_queue.sqs_id
    sqs_queue_arn     = module.person_search_queue.sqs_arn
    sqs_queue_name    = module.person_search_queue.sqs_name
  }
}

resource "kubernetes_secret" "person_search_dead_letter_queue" {
  metadata {
    name      = "person-search-sqs-dl-instance-output"
    namespace = "hmpps-probation-search-dev"
  }
  data = {
    access_key_id     = module.person_search_dead_letter_queue.access_key_id
    secret_access_key = module.person_search_dead_letter_queue.secret_access_key
    sqs_queue_url     = module.person_search_dead_letter_queue.sqs_id
    sqs_queue_arn     = module.person_search_dead_letter_queue.sqs_arn
    sqs_queue_name    = module.person_search_dead_letter_queue.sqs_name
  }
}

resource "aws_sns_topic_subscription" "person_search_subscription" {
  provider      = aws.london
  topic_arn     = module.probation_offender_events.topic_arn
  protocol      = "sqs"
  endpoint      = module.person_search_queue.sqs_arn
  filter_policy = <<EOT
  {
    "eventType": [
        "OFFENDER_CHANGED",
        "OFFENDER_MANAGER_CHANGED",
        "OFFENDER_REGISTRATION_CHANGED",
        "OFFENDER_REGISTRATION_DEREGISTERED",
        "OFFENDER_REGISTRATION_DELETED",
        "SENTENCE_CHANGED",
        "CONVICTION_CHANGED"
    ]
  }
  EOT


}

