provider "pingdom" {
}

resource "pingdom_check" "hmpps-assess-risks-and-needs-prod" {
  type                     = "http"
  name                     = "HMPPS - assess-risks-and-needs API"
  host                     = "assess-risks-and-needs.hmpps.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/health"
  encryption               = true
  port                     = 443
  tags                     = "hmpps,cloudplatform-managed"
  probefilters             = "region:EU"
  integrationids           = [127850]
}