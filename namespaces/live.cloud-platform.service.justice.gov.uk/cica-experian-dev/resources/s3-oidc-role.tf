data "aws_eks_cluster" "eks_cluster" {
  name = var.eks_cluster_name
}

data "aws_secretsmanager_secret" "circleci" {
  name = "cloud-platform-circleci"
}

data "aws_secretsmanager_secret_version" "circleci" {
  secret_id = data.aws_secretsmanager_secret.circleci.id
}

data "aws_eks_cluster" "eks_cluster" {
  name = var.eks_cluster_name
}

module "bankwizard_bucket_assumable_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "5.13.0"
  create_role = true
  role_name = "bankwizard-bucket-assumable-role"
  provider_url = data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
  role_policy_arns = [module.bankwizard_artifact_bucket.irsa_policy_arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${var.namespace}:${var.service_account_name}"]
}

resource "kubernetes_secret" "bankwizard_artifact_bucket_role" {
  metadata {
    name      = "bankwizard-artifact-bucket-role-output"
    namespace = var.namespace
  }

  data = {
    bucket_role_arn = module.bankwizard_bucket_assumable_role.iam_role_arn
  }
}
