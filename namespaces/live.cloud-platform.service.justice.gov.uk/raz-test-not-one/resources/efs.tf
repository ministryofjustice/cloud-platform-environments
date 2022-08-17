
module "efs" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-efs-pv?ref=frist"

  cluster_name           = "live"
  namespace              = var.namespace
  application            = var.application
  business_unit          = var.business_unit
  environment            = var.environment
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  team_name              = var.team_name
  slack_channel          = var.slack_channel

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "efs_id" {
  metadata {
    name      = "efs-id"
    namespace = var.namespace
  }
  data = {
    efs-id = module.efs.efs_id
  }
}
