module "raz_test_dms" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-dms?ref=new-use"

  cluster_name           = var.cluster_name
  namespace              = var.namespace
  application            = var.application
  business-unit          = var.business_unit
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  is-production          = var.is_production
  team_name              = var.team_name
}

resource "kubernetes_secret" "dms_instance" {
  metadata {
    name      = "dms-instance"
    namespace = var.namespace
  }

  data = {
    replication_instance_arn  = module.raz_test_dms.replication_instance_arn
  }
}
