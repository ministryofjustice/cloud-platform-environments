
module "ingress_controller" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-teams-ingress-controller?ref=0.0.1"

  namespace     = "mogaal-test"
  hostzone_name = "mogaal-test.cloud-platform.service.justice.gov.uk"
}
