module "github_actions_service_account" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"
  application            = var.application
  business_unit          = var.business_unit
  eks_cluster_name       = var.eks_cluster_name
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name

  service_account_name = "cd-serviceaccount"
  role_policy_arns     = { for key, policy in aws_iam_policy.sqs_management_policy : key => policy.arn }
}

resource "kubernetes_role" "github_actions_role" {
  metadata {
    name      = "serviceaccount-role"
    namespace = var.namespace
  }
  dynamic "rule" {
    for_each = var.serviceaccount_rules
    content {
      api_groups = rule.value.api_groups
      resources  = rule.value.resources
      verbs      = rule.value.verbs
    }
  }
}

resource "kubernetes_role_binding" "github-actions-rolebinding" {
  metadata {
    name      = "serviceaccount-rolebinding"
    namespace = var.namespace
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.github_actions_role.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = module.github_actions_service_account.service_account.name
    namespace = var.namespace
  }
}

data "kubernetes_service_account" "service_account" {
  metadata {
    name      = "cd-serviceaccount"
    namespace = var.namespace
  }
}

data "kubernetes_secret" "service_account_secret" {
  metadata {
    name      = data.kubernetes_service_account.service_account.default_secret_name
    namespace = var.namespace
  }
}

resource "github_actions_environment_secret" "github_secrets" {
  for_each = {
    (var.github_actions_secret_kube_cluster)   = var.kubernetes_cluster
    (var.github_actions_secret_kube_namespace) = var.namespace
    (var.github_actions_secret_kube_cert)      = lookup(data.kubernetes_secret.service_account_secret.data, "ca.crt")
    (var.github_actions_secret_kube_token)     = lookup(data.kubernetes_secret.service_account_secret.data, "token")
  }
  repository      = "hmpps-probation-integration-services"
  environment     = var.github_environment
  secret_name     = each.key
  plaintext_value = each.value
}
