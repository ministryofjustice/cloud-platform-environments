module "ingress_controller" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-teams-ingress-controller?ref=0.0.3"

  namespace = "manage-hmpps-auth-accounts-preprod"
}
