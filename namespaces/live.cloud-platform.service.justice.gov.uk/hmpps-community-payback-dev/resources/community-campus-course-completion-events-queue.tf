module "community_campus_course_completion_events_queue" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  sqs_name                   = "community_campus_course_completion_events_queue"
  message_retention_seconds  = 7 * 24 * 3600 # 1 week
  visibility_timeout_seconds = 120    # 2 minutes
  redrive_policy             = jsonencode({
    deadLetterTargetArn = module.community_campus_course_completion_events_dlq.sqs_arn
    maxReceiveCount     = 3
  })

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "community_campus_course_completion_events_queue_secret" {
  metadata {
    name      = "sqs-community-campus-course-completion-events-secret"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.community_campus_course_completion_events_queue.sqs_id
    sqs_queue_arn  = module.community_campus_course_completion_events_queue.sqs_arn
    sqs_queue_name = module.community_campus_course_completion_events_queue.sqs_name
  }
}

module "community_campus_course_completion_events_dlq" {
  source                     = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  sqs_name                   = "community_campus_course_completion_events_dlq"
  message_retention_seconds  = 7 * 24 * 3600 # 1 week
  visibility_timeout_seconds = 120    # 2 minutes

  business_unit              = var.business_unit
  application                = var.application
  is_production              = var.is_production
  team_name                  = var.team_name
  namespace                  = var.namespace
  environment_name           = var.environment
  infrastructure_support     = var.infrastructure_support
}
