resource "pingdom_check" "ppud_automation_api_health" {
  type                     = "http"
  name                     = "hmpps-ppud-automation-api /health - PROD"
  host                     = "health-kick.prison.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/https/hmpps-ppud-automation-api.hmpps.service.justice.gov.uk/health/ping"
  encryption               = true
  port                     = 443
  tags                     = "hmpps,make-recall-decision,isproduction_true,cloudplatform-managed"
  probefilters             = "region:EU"
  integrationids           = [121586]
}
