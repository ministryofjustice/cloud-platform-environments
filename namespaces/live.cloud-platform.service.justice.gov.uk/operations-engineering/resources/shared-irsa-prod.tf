# `shared-*.tf` files contain resources used across multiple services

module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # IRSA configuration
  service_account_name = "operations-engineering"
  namespace            = var.namespace # this is also used as a tag

  # Attach the approprate policies using a key => value map
  # If you're using Cloud Platform provided modules (e.g. SNS, S3), these
  # provide an output called `irsa_policy_arn` that can be used.
  role_policy_arns = {
    dynamo_ap_gh_collab  = module.ap_gh_collab_repo_tf_state_lock.irsa_policy_arn
    dynamo_moj_gh_collab = module.opseng_tf_state_lock.irsa_policy_arn
    s3_ap_gh_collab      = module.ap_gh_collab_repo_s3_bucket.irsa_policy_arn
    s3_moj_gh_collab     = module.s3_bucket.irsa_policy_arn
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "irsa" {
  metadata {
    name      = "irsa-output"
    namespace = var.namespace
  }
  data = {
    role           = module.irsa.role_name
    serviceaccount = module.irsa.service_account.name
    rolearn        = module.irsa.role_arn
  }
}
