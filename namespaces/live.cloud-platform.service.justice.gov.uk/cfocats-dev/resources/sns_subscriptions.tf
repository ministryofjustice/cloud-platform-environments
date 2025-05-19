# Overnight service
resource "aws_sns_topic_subscription" "overnight_sync_participant" {
  topic_arn     = module.sync_participant_command.topic_arn
  endpoint      = module.sqs_overnight.sqs_arn
  protocol      = "sqs"
}

# Tasks service
resource "aws_sns_topic_subscription" "tasks_objectivetask_completed" {
  topic_arn     = module.objectivetask_completed_event.topic_arn
  endpoint      = module.sqs_tasks.sqs_arn
  protocol      = "sqs"
}

resource "aws_sns_topic_subscription" "tasks_participant_transitioned" {
  topic_arn     = module.participant_transitioned_event.topic_arn
  endpoint      = module.sqs_tasks.sqs_arn
  protocol      = "sqs"
}

# Payment service
resource "aws_sns_topic_subscription" "payment_activity_approved" {
  topic_arn     = module.activity_approved_event.topic_arn
  endpoint      = module.sqs_payment.sqs_arn
  protocol      = "sqs"
}

resource "aws_sns_topic_subscription" "payment_participant_transitioned" {
  topic_arn     = module.participant_transitioned_event.topic_arn
  endpoint      = module.sqs_payment.sqs_arn
  protocol      = "sqs"
}

resource "aws_sns_topic_subscription" "payment_hub_induction_created" {
  topic_arn     = module.hub_induction_created_event.topic_arn
  endpoint      = module.sqs_payment.sqs_arn
  protocol      = "sqs"
}

resource "aws_sns_topic_subscription" "payment_pri_assigned" {
  topic_arn     = module.pri_assigned_event.topic_arn
  endpoint      = module.sqs_payment.sqs_arn
  protocol      = "sqs"
}

resource "aws_sns_topic_subscription" "payment_pri_ttg_completed" {
  topic_arn     = module.pri_ttg_completed_event.topic_arn
  endpoint      = module.sqs_payment.sqs_arn
  protocol      = "sqs"
}

resource "aws_sns_topic_subscription" "payment_wing_induction_created" {
  topic_arn     = module.wing_induction_created_event.topic_arn
  endpoint      = module.sqs_payment.sqs_arn
  protocol      = "sqs"
}