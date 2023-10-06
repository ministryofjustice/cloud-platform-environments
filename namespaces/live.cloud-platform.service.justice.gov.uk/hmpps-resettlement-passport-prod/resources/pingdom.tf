
provider "pingdom" {
}

resource "pingdom_check" "resettlement-passport-prod" {
  type                     = "http"
  name                     = "resettlement passport - prod"
  host                     = "resettlement-passport-ui.hmpps.service.justice.gov.uk/"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_HMPPS,application_resettlement-passport,component_healthcheck,isproduction_true,environment_prod"
  probefilters             = "region:EU"
}