module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  # EKS config
  eks_cluster_name     = var.eks_cluster_name
  service_account_name = "${var.team_name}-${var.environment}"

  # IRSA configuration
  role_policy_arns = {
    s3              = module.s3.irsa_policy_arn
    rds             = module.rds.irsa_policy_arn
    sns_fileupload  = module.sns_topic_fileupload.irsa_policy_arn
    sns_personid    = module.sns_topic_personid.irsa_policy_arn
    sqs_fileupload  = aws_iam_policy.fileupload_sqs_irsa.arn
    sqs_personid    = aws_iam_policy.personid_sqs_irsa.arn
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
