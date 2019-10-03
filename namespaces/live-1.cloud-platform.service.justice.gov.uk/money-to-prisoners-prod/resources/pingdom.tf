provider "pingdom" {}

resource "pingdom_check" "money-to-prisoners-prod-send-money" {
  name = "money-to-prisoners-prod-send-money"
  tags = "businessunit_${var.business-unit},application_${var.application},component_send-money,isproduction_${var.is-production},environment_${var.environment-name}"
  host = "send-money-to-prisoner.service.gov.uk"
  url  = "/ping.json"

  type         = "http"
  encryption   = true
  port         = 443
  probefilters = "region:EU"
  publicreport = "false"

  stringtoexpect = "version_number" # a key that appears in ping.json

  resolution               = 5
  sendnotificationwhendown = 1
  notifyagainevery         = 0
  notifywhenbackup         = true
  integrationids           = [79851]
}
