module "ingress_controller" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-teams-ingress-controller?ref=0.0.8"

  namespace     = "pathfinder-preprod"
  is_production = var.is_production
}
