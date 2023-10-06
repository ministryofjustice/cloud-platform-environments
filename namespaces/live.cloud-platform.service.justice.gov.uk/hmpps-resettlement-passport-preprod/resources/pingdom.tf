provider "pingdom" {
}

resource "pingdom_check" "resettlement-passport-preprod" {
  type                     = "http"
  name                     = "resettlement passport - preprod"
  host                     = "resettlement-passport-ui-preprod.hmpps.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/"
  encryption               = true
  port                     = 443
  tags                     = "HMPPS,resettlementpassport,component_healthcheck,isproduction_false,environment_preprod"
  probefilters             = "region:EU"
}