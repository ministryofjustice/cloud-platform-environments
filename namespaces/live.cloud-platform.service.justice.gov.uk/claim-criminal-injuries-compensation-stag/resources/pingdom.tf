
provider "pingdom" {
}

resource "pingdom_check" "claim-criminal-injuries-compensation-stag" {
  type                     = "http"
  name                     = "cica - stag - cloud-platform - claim"
  host                     = "stag.claim-criminal-injuries-compensation.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_platforms,application_prometheus,component_healthcheck,isproduction_true,environment_uat,infrastructuresupport_platforms"
  probefilters             = "region:EU"
}

