module "ingress_controller" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-teams-ingress-controller?ref=0.1.2"

  namespace     = var.namespace
  is_production = var.is-production
}
