provider "pingdom" {}

resource "pingdom_check" "parliamentary-questions-production-cloud-platform-healthcheck" {
  type                     = "http"
  name                     = "Parliamentary Questions - Production - cloud-platform - Healthcheck"
  host                     = "trackparliamentaryquestions.service.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 3
  notifyagainevery         = 0
  url                      = "/healthcheck"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_central_digital,application_parliamentary_questions,component_healthcheck,isproduction_true,environment_prod,infrastructuresupport_staff_tools_and_services"
  probefilters             = "region:EU"
  publicreport             = "true"
  integrationids           = [100563, 98672]
}
