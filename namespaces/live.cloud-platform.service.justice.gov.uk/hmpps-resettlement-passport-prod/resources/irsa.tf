module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # IRSA configuration
  service_account_name = "${var.namespace}-irsa"
  namespace            = var.namespace # this is also used as a tag

  # Attach the approprate policies using a key => value map
  # If you're using Cloud Platform provided modules (e.g. SNS, S3), these
  # provide an output called `irsa_policy_arn` that can be used.
  role_policy_arns = {
    s3 = module.s3_bucket.irsa_policy_arn
    offender-event-queue = module.offender-event-queue.irsa_policy_arn
    offender-event-dlq = module.offender-event-dlq.irsa_policy_arn
    document-storage-s3 = module.document_storage_s3_bucket.irsa_policy_arn
    audit_sqs = data.kubernetes_secret.audit_secret.data.irsa_policy_arn
    rds = module.rds.irsa_policy_arn
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}
