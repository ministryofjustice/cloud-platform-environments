provider "pingdom" {
}

resource "pingdom_check" "laa-legal-adviser-api-search" {
  type                     = "http"
  name                     = "LAA Legal Adviser API Search [production]"
  host                     = "laa-legal-adviser-api-production.cloud-platform.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/ping.json"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_${lower(var.business-unit)},application_${lower(var.application)},component_ping,isproduction_${var.is-production},environment_${lower(var.environment-name)},infrastructuresupport_${lower(var.application)}"
  probefilters             = "region:EU"
  publicreport             = "true"
  integrationids           = [87631, 83320]
}

resource "pingdom_check" "laa-legal-adviser-api-admin" {
  type                     = "http"
  name                     = "LAA Legal Adviser API Admin [production]"
  host                     = "laa-legal-adviser-api-production.cloud-platform.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/healthcheck.json"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_${lower(var.business-unit)},application_${lower(var.application)},component_ping,isproduction_${var.is-production},environment_${lower(var.environment-name)},infrastructuresupport_${lower(var.application)}"
  probefilters             = "region:EU"
  publicreport             = "true"
  integrationids           = [87631, 83320]
}

