resource "pingdom_check" "make_recall_decision_ui_health" {
  type                     = "http"
  name                     = "make-recall-decision-ui /ping - PROD"
  host                     = "make-recall-decision.hmpps.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/ping"
  encryption               = true
  port                     = 443
  tags                     = "hmpps,make-recall-decision,prod,isproduction_true,cloudplatform-managed"
  probefilters             = "region:EU"
  integrationids           = [121587]
}

resource "pingdom_check" "make_recall_decision_api_health" {
  type                     = "http"
  name                     = "make-recall-decision-api /health - PROD"
  host                     = "make-recall-decision-api.hmpps.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/health"
  encryption               = true
  port                     = 443
  tags                     = "hmpps,make-recall-decision,prod,isproduction_true,cloudplatform-managed"
  probefilters             = "region:EU"
  integrationids           = [121587]
}
