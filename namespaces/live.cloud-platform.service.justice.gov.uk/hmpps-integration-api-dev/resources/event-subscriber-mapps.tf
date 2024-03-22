module "event_mapps_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name                  = "events_mapps_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.event_mapps_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
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

module "event_mapps_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name        = "event_mapps_queue_dl"
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

resource "aws_sqs_queue_policy" "event_mapps_queue_policy" {
  queue_url = module.event_mapps_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.event_mapps_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.event_mapps_queue.sqs_arn}",
          "Action": "SQS:SendMessage",
          "Condition":
            {
              "ArnEquals":
                {
                  "aws:SourceArn": "${environmmodule.hmpps-integration-events.topic_arn}"
                }
            }
        }
      ]
  }
   EOF
}

module "mapps-filter-list-secret" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-secrets-manager?ref=3.0.4"
  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # Secrets configuration
  secrets = {
    "integration-api-event-mapps-filter-list" = {
      description             = "MAPPS event filter list",
      recovery_window_in_days = 7,
      k8s_secret_name         = "mapps-filter-list"
    },
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london_default_github_tag
  }
}



resource "aws_sns_topic_subscription" "event_mapps_subscription" {
  provider  = aws.london
  topic_arn = environmmodule.hmpps-integration-events.topic_arn
  protocol  = "sqs"
  endpoint  = module.event_mapps_queue.sqs_arn 
}

resource "kubernetes_secret" "event_mapps_queue" {
  metadata {
    name      = "event-mapps-queue"
    namespace = var.namespace
  }

  data = {
    sqs_id   = module.event_mapps_queue.sqs_id
    sqs_arn  = module.event_mapps_queue.sqs_arn
    sqs_name = module.event_mapps_queue.sqs_name
  }
}

resource "kubernetes_secret" "event_mapps_dead_letter_queue" {
  metadata {
    name      = "event-mapps-dl-queue"
    namespace = var.namespace
  }

  data = {
    sqs_id   = module.event_mapps_dead_letter_queue.sqs_id
    sqs_arn  = module.event_mapps_dead_letter_queue.sqs_arn
    sqs_name = module.event_mapps_dead_letter_queue.sqs_name
  }
}
