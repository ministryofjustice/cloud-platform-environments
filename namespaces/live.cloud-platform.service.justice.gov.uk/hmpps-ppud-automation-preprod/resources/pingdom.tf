resource "pingdom_check" "ppud_automation_api_health" {
  type                     = "http"
  name                     = "hmpps-ppud-automation-api /health - PREPROD"
  host                     = "hmpps-ppud-automation-api-preprod.hmpps.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/health"
  encryption               = true
  port                     = 443
  tags                     = "hmpps,make-recall-decision,preprod,isproduction_false,cloudplatform-managed"
  probefilters             = "region:EU"
  integrationids           = [121586]
}
