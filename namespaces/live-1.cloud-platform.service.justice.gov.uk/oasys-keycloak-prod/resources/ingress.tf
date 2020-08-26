module "ingress_controller" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-teams-ingress-controller?ref=0.0.6"

  namespace = "oasys-keycloak-prod"
  is_production = var.is_production
}
