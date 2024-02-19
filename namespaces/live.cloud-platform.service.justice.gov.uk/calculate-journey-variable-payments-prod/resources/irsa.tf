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
    s3   = module.calculate-journey-variable-payments_s3_bucket.irsa_policy_arn
    rds  = module.rds-instance.irsa_policy_arn
    basm = data.aws_ssm_parameter.basm-bucket.value
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support
}
data "aws_ssm_parameter" "basm-bucket" {
  name = "/hmpps-book-secure-move-api-production/reporting-bucket/irsa-policy-arn"
}
data "aws_ssm_parameter" "basm-bucket-name" {
  name = "/hmpps-book-secure-move-api-production/reporting-bucket/bucket-name"
}

resource "kubernetes_secret" "basm_reporting_bucket" {
  metadata {
    name      = "basm-reporting-bucket"
    namespace = var.namespace
  }

  data = {
    bucket_name = data.aws_ssm_parameter.basm-bucket-name.value
  }
}