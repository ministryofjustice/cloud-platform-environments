module "ingress_controller" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-teams-ingress-controller?ref=0.1.0"

  namespace     = "prisoner-offender-search-prod"
  is_production = var.is-production
}
