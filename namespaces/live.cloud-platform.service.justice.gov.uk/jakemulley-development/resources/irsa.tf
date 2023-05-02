resource "irsa" {
  eks_cluster_name = var.eks_cluster_name
  namespace = var.namespace

  role_policy_arns = [module.sqs.aws_iam_policy_arn]
}
