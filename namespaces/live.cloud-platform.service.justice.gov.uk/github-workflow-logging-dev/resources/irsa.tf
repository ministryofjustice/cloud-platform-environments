# ── IRSA: runtime workload AWS access ────────────────────────────────────────

module "workload_irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  eks_cluster_name = var.eks_cluster_name

  service_account_name = "github-workflow-logging-workload"
  namespace            = var.namespace

  role_policy_arns = {
    sqs_log_events = module.log_events_queue.irsa_policy_arn
    sns_log_events = module.log_events_topic.irsa_policy_arn
    s3_snapshots   = module.snapshots_bucket.irsa_policy_arn
    s3_backfill    = module.backfill_state_bucket.irsa_policy_arn
  }

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}
