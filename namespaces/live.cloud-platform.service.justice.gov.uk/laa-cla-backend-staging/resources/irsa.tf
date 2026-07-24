resource "aws_iam_policy" "rds_pitr_restore" {
  name = "${var.namespace}-rds-pitr-restore"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "rds:RestoreDBInstanceToPointInTime"
        ]
        Resource = "*"
      }
    ]
  })
}

module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # IRSA configuration
  service_account_name = "${var.namespace}-irsa-sevice-account"
  namespace            = var.namespace

  # Attach the approprate policies using a key => value map
  # If you're using Cloud Platform provided modules (e.g. SNS, S3), these
  # provide an output called `irsa_policy_arn` that can be used.
  role_policy_arns = {
    rds_pitr_restore = aws_iam_policy.rds_pitr_restore.arn
    rds_cla_backend_rds_postgres_14       = module.cla_backend_rds_postgres_14.irsa_policy_arn
    s3_cla_backend_private_reports_bucket = module.cla_backend_private_reports_bucket.irsa_policy_arn
    s3_cla_backend_deleted_objects_bucket = module.cla_backend_deleted_objects_bucket.irsa_policy_arn
    s3_cla_backend_static_files_bucket    = module.cla_backend_static_files_bucket.irsa_policy_arn
    sqs_laa_cla_backend_staging_sqs       = module.laa_cla_backend_staging_sqs.irsa_policy_arn
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support
}

