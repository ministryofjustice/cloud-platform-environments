module "runner-irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"

  eks_cluster_name = var.eks_cluster_name

  service_account_name = "runner-irsa-${var.environment-name}"
  namespace            = var.namespace # this is also used as a tag

  role_policy_arns = {
    metadatas3 = data.kubernetes_secret.service-metadata-s3-arn-cross-namespace.data.s3arn
  }

  team_name              = var.team_name
  business_unit          = "transformed-department"
  application            = "formbuilderrunner"
  is_production          = var.is_production
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support
}

data "kubernetes_secret" "service-metadata-s3-arn-cross-namespace" {
  metadata {
    name      = "service-metadata-s3-policy-arn"
    namespace = var.namespace
  }
}