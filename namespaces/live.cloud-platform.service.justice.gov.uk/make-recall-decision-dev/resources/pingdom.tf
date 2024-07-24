resource "pingdom_check" "make_recall_decision_ui_health" {
  type                     = "http"
  name                     = "make-recall-decision-ui /ping - DEV"
  host                     = "make-recall-decision-dev.hmpps.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/ping"
  encryption               = true
  port                     = 443
  tags                     = "hmpps,make-recall-decision,dev,isproduction_false,cloudplatform-managed"
  probefilters             = "region:EU"
  integrationids           = [121586]
}

resource "pingdom_check" "make_recall_decision_api_health" {
  type                     = "http"
  name                     = "make-recall-decision-api /health - DEV"
  host                     = "make-recall-decision-api-dev.hmpps.service.justice.gov.uk"
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
