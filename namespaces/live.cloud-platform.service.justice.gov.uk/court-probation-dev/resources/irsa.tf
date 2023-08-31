module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # IRSA configuration
  service_account_name = var.application
  namespace            = var.namespace # this is also used as a tag

  # Attach the approprate policies using a key => value map
  # If you're using Cloud Platform provided modules (e.g. SNS, S3), these
  # provide an output called `irsa_policy_arn` that can be used.
  role_policy_arns = {
    rds = module.court_case_service_rds.irsa_policy_arn
    s3  = module.crime-portal-gateway-s3-bucket.irsa_policy_arn
    sns_cce = module.court-case-events.irsa_policy_arn
    sqs_cpg = module.crime-portal-gateway-queue.irsa_policy_arn
    sqs_cpg_dlq = module.crime-portal-gateway-dead-letter-queue.irsa_policy_arn
    sqs_ccm = module.court-case-matcher-queue.irsa_policy_arn
    sqs_ccm_dlq = module.court-case-matcher-dead-letter-queue.irsa_policy_arn
    elasticache = module.pac_elasticache_redis.irsa_policy_arn
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support
}