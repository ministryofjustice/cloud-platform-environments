module "ingress_controller" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-teams-ingress-controller?ref=0.0.4"

  namespace = "hmpps-book-secure-move-frontend-uat"
}
