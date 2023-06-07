module "offender_events_ui_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.11.0"

  environment-name          = var.environment
  team_name                 = var.team_name
  infrastructure-support    = var.infrastructure_support
  application               = var.application
  sqs_name                  = "offender_events_ui_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600
  namespace                 = var.namespace

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.offender_events_ui_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
  }

EOF


  providers = {
    aws = aws.london
  }
}

resource "aws_sqs_queue_policy" "offender_events_ui_queue_policy" {
  queue_url = module.offender_events_ui_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.offender_events_ui_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.offender_events_ui_queue.sqs_arn}",
          "Action": "SQS:SendMessage",
          "Condition":
                      {
                        "ArnEquals":
                          {
                            "aws:SourceArn": ["${module.offender_events.topic_arn}", "${module.probation_offender_events.topic_arn}", "${data.aws_sns_topic.hmpps-domain-events.arn}"]
                          }
                        }
        }
      ]
  }

EOF

}

module "offender_events_ui_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.11.0"

  environment-name       = var.environment
  team_name              = var.team_name
  infrastructure-support = var.infrastructure_support
  application            = var.application
  sqs_name               = "offender_events_ui_queue_dl"
  encrypt_sqs_kms        = "true"
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "offender_events_ui_queue" {
  metadata {
    name      = "oeu-sqs-instance-output"
    namespace = var.namespace
  }

  data = {
    sqs_ptpu_url  = module.offender_events_ui_queue.sqs_id
    sqs_ptpu_arn  = module.offender_events_ui_queue.sqs_arn
    sqs_ptpu_name = module.offender_events_ui_queue.sqs_name
  }
}

resource "kubernetes_secret" "offender_events_ui_dead_letter_queue" {
  metadata {
    name      = "oeu-sqs-dl-instance-output"
    namespace = var.namespace
  }

  data = {
    sqs_ptpu_url  = module.offender_events_ui_dead_letter_queue.sqs_id
    sqs_ptpu_arn  = module.offender_events_ui_dead_letter_queue.sqs_arn
    sqs_ptpu_name = module.offender_events_ui_dead_letter_queue.sqs_name
  }
}

resource "aws_sns_topic_subscription" "ou_events_ui_prison_subscription" {
  provider  = aws.london
  topic_arn = module.offender_events.topic_arn
  protocol  = "sqs"
  endpoint  = module.offender_events_ui_queue.sqs_arn
}

resource "aws_sns_topic_subscription" "ou_events_ui_probation_subscription" {
  provider  = aws.london
  topic_arn = module.probation_offender_events.topic_arn
  protocol  = "sqs"
  endpoint  = module.offender_events_ui_queue.sqs_arn
}

data "aws_sns_topic" "hmpps-domain-events" {
  name = "cloud-platform-Digital-Prison-Services-e29fb030a51b3576dd645aa5e460e573"
}

resource "aws_sns_topic_subscription" "ou_events_ui_domain_subscription" {
  provider  = aws.london
  topic_arn = data.aws_sns_topic.hmpps-domain-events.arn
  protocol  = "sqs"
  endpoint  = module.offender_events_ui_queue.sqs_arn
}

# IRSA role for offender-events-ui app
module "offender-events-ui-irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"

  eks_cluster_name     = var.eks_cluster_name
  namespace            = var.namespace
  service_account_name = "offender-events-ui"
  role_policy_arns = {
    offender_events_ui_dead_letter_queue = module.offender_events_ui_dead_letter_queue.irsa_policy_arn,
    offender_events_ui_queue             = module.offender_events_ui_queue.irsa_policy_arn
  }
  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}
