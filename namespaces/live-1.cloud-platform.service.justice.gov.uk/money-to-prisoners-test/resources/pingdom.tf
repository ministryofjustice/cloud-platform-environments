provider "pingdom" {}

resource "pingdom_check" "money-to-prisoners-test-api" {
  name = "money-to-prisoners-test-api"
  tags = "businessunit_${var.business-unit},application_${var.application},component_api,isproduction_${var.is-production},environment_${var.environment-name}"
  host = "api-test.prisoner-money.service.justice.gov.uk"
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

resource "pingdom_check" "money-to-prisoners-test-cashbook" {
  name = "money-to-prisoners-test-cashbook"
  tags = "businessunit_${var.business-unit},application_${var.application},component_cashbook,isproduction_${var.is-production},environment_${var.environment-name}"
  host = "cashbook-test.prisoner-money.service.justice.gov.uk"
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

resource "pingdom_check" "money-to-prisoners-test-bank-admin" {
  name = "money-to-prisoners-test-bank-admin"
  tags = "businessunit_${var.business-unit},application_${var.application},component_bank-admin,isproduction_${var.is-production},environment_${var.environment-name}"
  host = "bank-admin-test.prisoner-money.service.justice.gov.uk"
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

resource "pingdom_check" "money-to-prisoners-test-noms-ops" {
  name = "money-to-prisoners-test-noms-ops"
  tags = "businessunit_${var.business-unit},application_${var.application},component_noms-ops,isproduction_${var.is-production},environment_${var.environment-name}"
  host = "noms-ops-test.prisoner-money.service.justice.gov.uk"
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

resource "pingdom_check" "money-to-prisoners-test-send-money" {
  name = "money-to-prisoners-test-send-money"
  tags = "businessunit_${var.business-unit},application_${var.application},component_send-money,isproduction_${var.is-production},environment_${var.environment-name}"
  host = "send-money-test.prisoner-money.service.justice.gov.uk"
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

resource "pingdom_check" "money-to-prisoners-test-start-page" {
  name = "money-to-prisoners-test-start-page"
  tags = "businessunit_${var.business-unit},application_${var.application},component_start-page,isproduction_${var.is-production},environment_${var.environment-name}"
  host = "start-page-test.prisoner-money.service.justice.gov.uk"
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
