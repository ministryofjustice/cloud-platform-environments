module "cvl_prison_events_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.10.1"

  environment-name          = var.environment-name
  team_name                 = var.team_name
  infrastructure-support    = var.infrastructure_support
  application               = var.application
  sqs_name                  = "cvl_prison_events_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600
  namespace                 = var.namespace

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.cvl_prison_events_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
  }
  EOF

  providers = {
    aws = aws.london
  }
}

module "cvl_probation_events_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.10.1"

  environment-name          = var.environment-name
  team_name                 = var.team_name
  infrastructure-support    = var.infrastructure_support
  application               = var.application
  sqs_name                  = "cvl_probation_events_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600
  namespace                 = var.namespace

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.cvl_probation_events_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
  }
  EOF

  providers = {
    aws = aws.london
  }
}

module "cvl_prison_events_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.10.1"

  environment-name       = var.environment-name
  team_name              = var.team_name
  infrastructure-support = var.infrastructure_support
  application            = var.application
  sqs_name               = "cvl_prison_events_queue_dl"
  encrypt_sqs_kms        = "true"
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

module "cvl_probation_events_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.10.1"

  environment-name       = var.environment-name
  team_name              = var.team_name
  infrastructure-support = var.infrastructure_support
  application            = var.application
  sqs_name               = "cvl_probation_events_queue_dl"
  encrypt_sqs_kms        = "true"
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}


resource "aws_sqs_queue_policy" "cvl_prison_events_queue_policy" {
  queue_url = module.cvl_prison_events_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.cvl_prison_events_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.cvl_prison_events_queue.sqs_arn}",
          "Action": "SQS:SendMessage",
          "Condition":
            {
              "ArnEquals":
                {
                  "aws:SourceArn": "${module.offender_events.topic_arn}"
                }
            }
        }
      ]
  }
   EOF
}

resource "aws_sqs_queue_policy" "cvl_probation_events_queue_policy" {
  queue_url = module.cvl_probation_events_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.cvl_probation_events_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.cvl_probation_events_queue.sqs_arn}",
          "Action": "SQS:SendMessage",
          "Condition":
            {
              "ArnEquals":
                {
                  "aws:SourceArn": "${module.probation_offender_events.topic_arn}"
                }
            }
        }
      ]
  }
   EOF
}

resource "aws_sns_topic_subscription" "cvl_prison_events_subscription" {
  provider      = aws.london
  topic_arn     = module.offender_events.topic_arn
  protocol      = "sqs"
  endpoint      = module.cvl_prison_events_queue.sqs_arn
  filter_policy = "{\"eventType\":[\"SENTENCE_DATES-CHANGED\", \"CONFIRMED_RELEASE_DATE-CHANGED\"]}"
}

resource "aws_sns_topic_subscription" "cvl_probation_events_subscription" {
  provider      = aws.london
  topic_arn     = module.probation_offender_events.topic_arn
  protocol      = "sqs"
  endpoint      = module.cvl_probation_events_queue.sqs_arn
  filter_policy = "{\"eventType\":[\"OFFENDER_MANAGER_CHANGED\"]}"
}

resource "kubernetes_secret" "create_and_vary_a_licence_prison_events_queue" {
  metadata {
    name      = "create-and-vary-a-licence-prison-events-sqs-instance-output"
    namespace = "create-and-vary-a-licence-preprod"
  }

  data = {
    access_key_id     = module.cvl_prison_events_queue.access_key_id
    secret_access_key = module.cvl_prison_events_queue.secret_access_key
    sqs_id            = module.cvl_prison_events_queue.sqs_id
    sqs_arn           = module.cvl_prison_events_queue.sqs_arn
    sqs_name          = module.cvl_prison_events_queue.sqs_name
  }
}

resource "kubernetes_secret" "create_and_vary_a_licence_probation_events_queue" {
  metadata {
    name      = "create-and-vary-a-licence-probation-events-sqs-instance-output"
    namespace = "create-and-vary-a-licence-preprod"
  }

  data = {
    access_key_id     = module.cvl_probation_events_queue.access_key_id
    secret_access_key = module.cvl_probation_events_queue.secret_access_key
    sqs_id            = module.cvl_probation_events_queue.sqs_id
    sqs_arn           = module.cvl_probation_events_queue.sqs_arn
    sqs_name          = module.cvl_probation_events_queue.sqs_name
  }
}

resource "kubernetes_secret" "create_and_vary_a_licence_prison_events_dead_letter_queue" {
  metadata {
    name      = "create-and-vary-a-licence-prison-events-sqs-dl-instance-output"
    namespace = "create-and-vary-a-licence-preprod"
  }

  data = {
    access_key_id     = module.cvl_prison_events_dead_letter_queue.access_key_id
    secret_access_key = module.cvl_prison_events_dead_letter_queue.secret_access_key
    sqs_id            = module.cvl_prison_events_dead_letter_queue.sqs_id
    sqs_arn           = module.cvl_prison_events_dead_letter_queue.sqs_arn
    sqs_name          = module.cvl_prison_events_dead_letter_queue.sqs_name
  }
}

resource "kubernetes_secret" "create_and_vary_a_licence_probation_events_dead_letter_queue" {
  metadata {
    name      = "create-and-vary-a-licence-probation-events-sqs-dl-instance-output"
    namespace = "create-and-vary-a-licence-preprod"
  }

  data = {
    access_key_id     = module.cvl_probation_events_dead_letter_queue.access_key_id
    secret_access_key = module.cvl_probation_events_dead_letter_queue.secret_access_key
    sqs_id            = module.cvl_probation_events_dead_letter_queue.sqs_id
    sqs_arn           = module.cvl_probation_events_dead_letter_queue.sqs_arn
    sqs_name          = module.cvl_probation_events_dead_letter_queue.sqs_name
  }
}
