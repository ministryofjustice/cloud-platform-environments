module "ingress_controller" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-teams-ingress-controller?ref=upgrade-teams-nginx"

  namespace = "mogaal-test"
}
