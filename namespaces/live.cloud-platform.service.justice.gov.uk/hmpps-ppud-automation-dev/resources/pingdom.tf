resource "pingdom_check" "ppud_automation_api_health" {
  type                     = "http"
  name                     = "hmpps-ppud-automation-api /health - DEV"
  host                     = "hmpps-ppud-automation-api-dev.hmpps.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/health"
  encryption               = true
  port                     = 443
  tags                     = "hmpps,make-recall-decision,dev,isproduction_false,cloudplatform-managed"
  probefilters             = "region:EU"
  integrationids           = [121586]
}
