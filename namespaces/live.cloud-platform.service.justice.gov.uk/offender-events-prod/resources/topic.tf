module "offender_events" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=5.0.1"

  # Confgiuration
  topic_display_name = "offender-events"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the topic
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

# for external access from hmpps-prisoner-events-prod in aks-studio-hosting-live-1
resource "aws_iam_user" "hmpps_prisoner_events" {
  name = "hmpps-prisoner-events-sns-user-${var.environment}"
  path = "/system/hmpps-prisoner-events-sns-user/"
}

resource "aws_iam_access_key" "hmpps_prisoner_events" {
  user = aws_iam_user.hmpps_prisoner_events.name
}

resource "aws_iam_user_policy_attachment" "hmpps_prisoner_events_policy" {
  policy_arn = module.offender_events.irsa_policy_arn
  user       = aws_iam_user.hmpps_prisoner_events.name
}

resource "kubernetes_secret" "hmpps_prisoner_events" {
  metadata {
    name      = "hmpps-prisoner-events"
    namespace = var.namespace
  }

  data = {
    topic_arn         = module.offender_events.topic_arn
    access_key_id     = aws_iam_access_key.hmpps_prisoner_events.id
    secret_access_key = aws_iam_access_key.hmpps_prisoner_events.secret
  }
}

resource "kubernetes_secret" "offender_events" {
  metadata {
    name      = "offender-events-topic"
    namespace = var.namespace
  }

  data = {
    topic_arn = module.offender_events.topic_arn
  }
}

resource "kubernetes_secret" "offender_case_notes" {
  metadata {
    name      = "offender-events-topic"
    namespace = "offender-case-notes-prod"
  }

  data = {
    topic_arn = module.offender_events.topic_arn
  }
}

module "probation_offender_events" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=5.0.1"

  # Configuration
  topic_display_name = "probation-offender-events"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the topic
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

module "offender_assessments_events" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=5.0.1"

  # Configuration
  topic_display_name = "offender-assessments-events"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the topic
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "offender_assessments_events" {
  metadata {
    name      = "offender-assessments-events-topic"
    namespace = var.namespace
  }
  data = {
    topic_arn = module.offender_assessments_events.topic_arn
  }
}

resource "kubernetes_secret" "offender-events-and-delius-topic-secret" {
  metadata {
    name      = "offender-events-and-delius-topic"
    namespace = "hmpps-probation-integration-services-${var.environment}"
  }
  data = {
    TOPIC_ARN = module.probation_offender_events.topic_arn
  }
}
