module "ingress_controller" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-teams-ingress-controller?ref=0.0.7"

  namespace = "manage-soc-cases-preprod"
  is_production = var.is_production
}
