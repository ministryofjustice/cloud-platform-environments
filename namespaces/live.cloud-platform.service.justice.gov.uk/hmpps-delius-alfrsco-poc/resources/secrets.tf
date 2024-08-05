module "secret" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-secrets-manager?ref=3.0.4"

  eks_cluster_name = var.eks_cluster_name

  # Secrets configuration
  secrets = {}

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_service" "rds_endpoint" {
  # set up a kube service to expose the RDS endpoint
  metadata {
    name      = "rds-endpoint"
    namespace = var.namespace
  }

  spec {
    external_name = module.rds_alfresco.rds_instance_endpoint

    port {
      port        = 5432
      target_port = 5432
    }
    session_affinity = "None"
    type             = "ExternalName"
  }
}
