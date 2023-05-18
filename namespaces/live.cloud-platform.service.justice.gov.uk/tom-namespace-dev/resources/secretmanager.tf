module "secrets_manager" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-secrets-manager?ref=main"
  team_name               = var.team_name
  application             = var.application
  business_unit           = var.business_unit
  is_production           = var.is_production
  namespace               = var.namespace
  environment             = var.environment
  infrastructure_support  = var.infrastructure_support
  serviceaccount_name = var.irsa_serviceaccount_name
  eks_cluster_name       = var.eks_cluster_name
  
  secrets = {
    "hello-world-app" = {
      description             = "Test secret for hello world",
      recovery_window_in_days = 15
      k8s_secret_name        = "hello-world-secret"
      k8s_secret_key = "POSTGRES_URL"
    },
        
    "multicontainer-app" = {
      description             = "Test secret for Multi container app",
      recovery_window_in_days = 15
      k8s_secret_name        = "multi-container-secret"
      k8s_secret_key = "MONDG_DB_URL"
    },
    "reference-app" = {
      description             = "Test secret for Multi container app",
      recovery_window_in_days = 7
      k8s_secret_name        = "reference-app-secret"
      k8s_secret_key = "MONDG_DB_URL"
    },
  }
}

#  New users
module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=1.1.0"

  eks_cluster_name =  var.eks_cluster_name
  namespace        = var.namespace
  role_policy_arns = [module.secrets_manager.irsa_policy_arn]
  service_account = var.irsa_serviceaccount_name
}

resource "kubernetes_secret" "irsa" {
  metadata {
    name      = "irsa"
    namespace = var.namespace
  }
  data = {
    role           = module.irsa.aws_iam_role_name
    serviceaccount = var.irsa_serviceaccount_name
  }
}

#  Existing users who have IRSA 
#  Add "module.secrets_manager.irsa_policy_arn" to the role_policy_arns in the irsa module 
