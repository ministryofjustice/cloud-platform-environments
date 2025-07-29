module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name
  
  # IRSA configuration
  service_account_name = var.namespace
  namespace            = var.namespace # this is also used as a tag

  role_policy_arns = {
    s3 = module.s3_bucket.irsa_policy_arn
    rds_mssql = module.rds_mssql.irsa_policy_arn
    redis = module.redis.irsa_policy_arn

    sqs_overnight = module.sqs_overnight.irsa_policy_arn
    sqs_payment  = module.sqs_payment.irsa_policy_arn
    sqs_tasks     = module.sqs_tasks.irsa_policy_arn

    sns_activity_approved_event        = module.activity_approved_event.irsa_policy_arn
    sns_hub_induction_created_event    = module.hub_induction_created_event.irsa_policy_arn
    sns_objectivetask_completed_event  = module.objectivetask_completed_event.irsa_policy_arn
    sns_participant_transitioned_event = module.participant_transitioned_event.irsa_policy_arn
    sns_pri_assigned_event             = module.pri_assigned_event.irsa_policy_arn
    sns_pri_ttg_completed_event        = module.pri_ttg_completed_event.irsa_policy_arn
    sns_sync_participant_command       = module.sync_participant_command.irsa_policy_arn
    sns_wing_induction_created_event   = module.wing_induction_created_event.irsa_policy_arn
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}