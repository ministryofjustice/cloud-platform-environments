# generated by https://github.com/ministryofjustice/money-to-prisoners-deploy
provider "pingdom" {}

resource "pingdom_check" "money-to-prisoners-test-emails" {
  name = "money-to-prisoners-test-emails"
  tags = "businessunit_${lower(var.business_unit)},application_${var.application},component_emails,isproduction_${var.is_production},environment_${var.environment}"
  host = "emails-test.prisoner-money.service.justice.gov.uk"
  url  = "/ping.json"

  type         = "http"
  encryption   = true
  port         = 443
  probefilters = "region:EU"

  stringtoexpect = "version_number" # a key that appears in ping.json

  resolution               = 5
  sendnotificationwhendown = 1
  notifyagainevery         = 0
  notifywhenbackup         = true
  integrationids           = [79851]
}
