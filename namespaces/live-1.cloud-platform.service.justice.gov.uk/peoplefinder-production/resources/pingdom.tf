provider "pingdom" {}

resource "pingdom_check" "peoplefinder-production-cloud-platform-healthcheck" {
  type                     = "http"
  name                     = "Peoplefinder - Production - cloud-platform - Healthcheck"
  host                     = "peoplefinder.service.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 3
  notifyagainevery         = 0
  url                      = "/healthcheck"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_central_digital,application_peoplefinder,component_healthcheck,isproduction_true,environment_prod,infrastructuresupport_staff_tools_and_services"
  probefilters             = "region:EU"
  publicreport             = "true"
  integrationids           = [98671, 98672]
}
