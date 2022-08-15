provider "pingdom" {
}

resource "pingdom_check" "evidencelibraryui-pingdom" {
  type                     = "http"
  name                     = "evidencelibraryui - production - cloud-platform"
  host                     = "analytical-evidence-library.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_hmpps,application_evidencelibraryui,component_ping,isproduction_true,environment_production,performance_hub_dev"
  probefilters             = "region:EU"
  integrationids           = [114774]
}

resource "pingdom_check" "evidencelibraryapi-pingdom" {
  type                     = "http"
  name                     = "evidencelibraryapi - production - cloud-platform"
  host                     = "evidence-library-api-prod.apps.live.cloud-platform.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/health"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_hmpps,application_evidencelibraryapi,component_ping,isproduction_true,environment_production,performance_hub_dev"
  probefilters             = "region:EU"
  integrationids           = [114774]
}