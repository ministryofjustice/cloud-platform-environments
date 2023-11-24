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
    s3_static_files_bucket = module.s3.irsa_policy_arn
    sqs_laalaa_sqs         = module.laalaa_sqs.irsa_policy_arn
    rds_rds_11             = module.rds_11.irsa_policy_arn
    rds_postgres_14        = module.laa_laa_rds_postgres_14.irsa_policy_arn
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment-name
  infrastructure_support = var.email
}
