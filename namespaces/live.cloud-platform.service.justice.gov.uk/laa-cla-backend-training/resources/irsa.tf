module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # IRSA configuration
  service_account_name = "${var.namespace}-irsa-sevice-account"
  namespace            = var.namespace

  # Attach the approprate policies using a key => value map
  # If you're using Cloud Platform provided modules (e.g. SNS, S3), these
  # provide an output called `irsa_policy_arn` that can be used.
  role_policy_arns = {
    rds_cla_backend_rds_postgres_14       = module.cla_backend_rds_postgres_14.irsa_policy_arn
    s3_cla_backend_private_reports_bucket = module.cla_backend_private_reports_bucket.irsa_policy_arn
    s3_cla_backend_deleted_objects_bucket = module.cla_backend_deleted_objects_bucket.irsa_policy_arn
    s3_cla_backend_static_files_bucket    = module.cla_backend_static_files_bucket.irsa_policy_arn
    sqs_laa_cla_backend_training_sqs      = module.laa_cla_backend_training_sqs.irsa_policy_arn
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support
}
