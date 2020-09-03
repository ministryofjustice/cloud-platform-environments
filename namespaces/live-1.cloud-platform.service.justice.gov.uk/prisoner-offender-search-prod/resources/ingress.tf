module "ingress_controller" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-teams-ingress-controller?ref=0.0.9"

  namespace     = "prisoner-offender-search-prod"
  is_production = var.is-production
}
