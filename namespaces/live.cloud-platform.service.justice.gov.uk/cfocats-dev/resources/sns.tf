module "activity_approved_event" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=5.1.0"

  topic_display_name = "activity_approved_event"
  encrypt_sns_kms    = true

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the topic
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

module "hub_induction_created_event" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=5.1.0"

  topic_display_name = "hub_induction_created_event"
  encrypt_sns_kms    = true

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the topic
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

module "objectivetask_completed_event" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=5.1.0"

  topic_display_name = "objectivetask_completed_event"
  encrypt_sns_kms    = true

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the topic
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

module "participant_transitioned_event" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=5.1.0"

  topic_display_name = "participant_transitioned_event"
  encrypt_sns_kms    = true

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the topic
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

module "pri_assigned_event" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=5.1.0"

  topic_display_name = "pri_assigned_event"
  encrypt_sns_kms    = true

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the topic
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

module "pri_ttg_completed_event" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=5.1.0"

  topic_display_name = "pri_ttg_completed_event"
  encrypt_sns_kms    = true

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the topic
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

module "sync_participant_command" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=5.1.0"

  topic_display_name = "sync_participant_command"
  encrypt_sns_kms    = true

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the topic
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

module "wing_induction_created_event" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=5.1.0"

  topic_display_name = "wing_induction_created_event"
  encrypt_sns_kms    = true

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the topic
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "sns_topic" {
  metadata {
    name      = "sns-topic-output"
    namespace = var.namespace
  }

  data = {
    activity_approved_event            = module.activity_approved_event.topic_name
    hub_induction_created_event        = module.hub_induction_created_event.topic_name
    objectivetask_completed_event      = module.objectivetask_completed_event.topic_name
    participant_transitioned_event     = module.participant_transitioned_event.topic_name
    pri_assigned_event                 = module.pri_assigned_event.topic_name
    pri_throughthegate_completed_event = module.pri_ttg_completed_event.topic_name
    sync_participant_command           = module.sync_participant_command.topic_name
    wing_induction_created_event       = module.wing_induction_created_event.topic_name
  }
}