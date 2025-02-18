data "aws_eks_cluster" "eks_cluster" {
  name = var.eks_cluster_name
}

data "aws_secretsmanager_secret" "circleci" {
  name = "cloud-platform-circleci"
}

data "aws_secretsmanager_secret_version" "circleci" {
  secret_id = data.aws_secretsmanager_secret.circleci.id
}

# locals {
#   circleci_organisation_id = jsondecode(data.aws_secretsmanager_secret_version.circleci.secret_string)["organisation_id"]
# }

# module "bankwizard_bucket_assumable_role" {
#   source = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
#   version = "5.13.0"
#   create_role = true
#   role_name = "bankwizard-bucket-assumable-role"
#   provider_url = "https://oidc.circleci.com/org/${local.circleci_organisation_id}"
#   role_policy_arns = [module.bankwizard_artifact_bucket.irsa_policy_arn]
#   oidc_fully_qualified_subjects = ["system:serviceaccount:${var.namespace}:${var.service_account_name}"]
# }

module "bankwizard_bucket_assumable_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "5.52.2"
  create_role = true
  role_name = "bankwizard-bucket-assumable-role"
  provider_url = "https://oidc.circleci.com/org/${jsondecode(data.aws_secretsmanager_secret_version.circleci.secret_string)["organisation_id"]}"
  role_policy_arns = [module.bankwizard_artifact_bucket.irsa_policy_arn]
  oidc_fully_qualified_subjects = ["${jsondecode(data.aws_secretsmanager_secret_version.circleci.secret_string)["organisation_id"]}"]
  provider_trust_policy_conditions = [
    {
      test     = "StringLike"
      variable = "oidc.circleci.com/org/${jsondecode(data.aws_secretsmanager_secret_version.circleci.secret_string)["organisation_id"]}:sub"
      values   = ["org/${jsondecode(data.aws_secretsmanager_secret_version.circleci.secret_string)["organisation_id"]}/project/07922d32-a0bc-4e11-9e28-9d574f9e7a0e/user/*"]
    }
  ]

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
