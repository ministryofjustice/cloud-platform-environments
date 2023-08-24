module "cvl_prison_events_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.12.0"

  # Queue configuration
  sqs_name                  = "cvl_prison_events_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.cvl_prison_events_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
  }
  EOF

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

module "cvl_probation_events_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.12.0"

  # Queue configuration
  sqs_name                  = "cvl_probation_events_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.cvl_probation_events_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
  }
  EOF

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

module "cvl_prison_events_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.12.0"

  # Queue configuration
  sqs_name        = "cvl_prison_events_queue_dl"
  encrypt_sqs_kms = "true"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

module "cvl_probation_events_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.12.0"

  # Queue configuration
  sqs_name        = "cvl_probation_events_queue_dl"
  encrypt_sqs_kms = "true"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

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
    namespace = "create-and-vary-a-licence-prod"
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
    namespace = "create-and-vary-a-licence-prod"
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
    namespace = "create-and-vary-a-licence-prod"
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
    namespace = "create-and-vary-a-licence-prod"
  }

  data = {
    access_key_id     = module.cvl_probation_events_dead_letter_queue.access_key_id
    secret_access_key = module.cvl_probation_events_dead_letter_queue.secret_access_key
    sqs_id            = module.cvl_probation_events_dead_letter_queue.sqs_id
    sqs_arn           = module.cvl_probation_events_dead_letter_queue.sqs_arn
    sqs_name          = module.cvl_probation_events_dead_letter_queue.sqs_name
  }
}
