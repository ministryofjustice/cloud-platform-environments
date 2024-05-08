resource "pingdom_check" "make_recall_decision_ui_health" {
  type                     = "http"
  name                     = "make-recall-decision-ui /ping - PRE-PROD"
  host                     = "make-recall-decision-preprod.hmpps.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/ping"
  encryption               = true
  port                     = 443
  tags                     = "hmpps,make-recall-decision,preprod,isproduction_false,cloudplatform-managed"
  probefilters             = "region:EU"
  integrationids           = [121586]
}

resource "pingdom_check" "make_recall_decision_api_health" {
  type                     = "http"
  name                     = "make-recall-decision-api /health - PRE-PROD"
  host                     = "make-recall-decision-api-preprod.hmpps.service.justice.gov.uk"
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
