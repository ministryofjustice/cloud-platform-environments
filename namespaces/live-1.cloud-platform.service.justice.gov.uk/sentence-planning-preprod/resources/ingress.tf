module "ingress_controller" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-teams-ingress-controller?ref=0.1.0"

  namespace = "sentence-planning-preprod"
}
