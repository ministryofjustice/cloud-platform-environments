module "ingress_controller" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-teams-ingress-controller?ref=0.0.8"

  namespace     = "prison-to-nhs-update-prod"
  is_production = var.is-production
}
