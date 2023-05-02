module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=1.1.0"

  eks_cluster_name = var.eks_cluster_name
  namespace        = var.namespace

  role_policy_arns = [
    module.dynamodb.irsa_policy_arn,
    module.s3.aws_iam_policy_arn,
    module.sns.aws_iam_policy_arn,
    module.sqs.aws_iam_policy_arn,
  ]
}
