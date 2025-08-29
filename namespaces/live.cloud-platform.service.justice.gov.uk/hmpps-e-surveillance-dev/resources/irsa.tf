module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  # EKS config
  eks_cluster_name     = var.eks_cluster_name
  service_account_name = "${var.team_name}-${var.environment}"

  # IRSA configuration
  role_policy_arns = {
    s3              = module.s3.irsa_policy_arn
    rds             = module.rds.irsa_policy_arn
    sns_file_upload = module.sns_topic_file_upload.irsa_policy_arn
    sns_person_id   = module.sns_topic_person_id.irsa_policy_arn
    sqs_file_upload = aws_iam_policy.file_upload_sqs_irsa.arn
    sqs_person_id   = aws_iam_policy.person_id_sqs_irsa.arn
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}
