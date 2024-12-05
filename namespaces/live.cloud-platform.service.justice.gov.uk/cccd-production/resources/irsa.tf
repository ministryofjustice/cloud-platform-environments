module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # IRSA configuration
  service_account_name = "cccd-production-service"
  namespace            = var.namespace # this is also used as a tag

  # Attach the approprate policies using a key => value map
  # If you're using Cloud Platform provided modules (e.g. SNS, S3), these
  # provide an output called `irsa_policy_arn` that can be used.
  role_policy_arns = {
    s3              = module.cccd_s3_bucket.irsa_policy_arn
    sns_submitted   = module.cccd_claims_submitted.irsa_policy_arn
    sqs_ccr         = module.claims_for_ccr.irsa_policy_arn
    sqs_cclf        = module.claims_for_cclf.irsa_policy_arn
    sqs_responses   = module.responses_for_cccd.irsa_policy_arn
    sqs_ccr_dlq     = module.ccr_dead_letter_queue.irsa_policy_arn
    sqs_cclf_dlq    = module.cclf_dead_letter_queue.irsa_policy_arn
    sqs_respons_dlq = module.cccd_response_dead_letter_queue.irsa_policy_arn
    rds             = module.cccd_rds.irsa_policy_arn
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support
}
