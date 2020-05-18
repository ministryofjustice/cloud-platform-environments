provider "pingdom" {}

resource "pingdom_check" "contact-moj-production-cloud-platform-healthcheck" {
  type                     = "http"
  name                     = "Contact MOJ - Production - cloud-platform - Healthcheck"
  host                     = "contact-moj.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 3
  notifyagainevery         = 0
  url                      = "/healthcheck"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_central_digital,application_contact-moj,component_healthcheck,isproduction_true,environment_prod,infrastructuresupport_staff_tools_and_services"
  probefilters             = "region:EU"
  publicreport             = "true"
  integrationids           = [98672, 103373]
}
