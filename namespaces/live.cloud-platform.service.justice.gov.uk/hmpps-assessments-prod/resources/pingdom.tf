provider "pingdom" {
}

resource "pingdom_check" "hmpps-assessments-prod" {
  type                     = "http"
  name                     = "HMPPS - Unpaid Work Assessments API"
  host                     = "api.hmpps-assessments.service.justice.gov.uk"
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