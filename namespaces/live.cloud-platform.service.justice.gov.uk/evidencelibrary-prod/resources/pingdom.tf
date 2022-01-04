provider "pingdom" {
}

resource "pingdom_check" "justicedata-pingdom" {
  type                     = "http"
  name                     = "evidencelibraryui - production - cloud-platform"
  host                     = "evidence-library-prod.apps.live.cloud-platform.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_hmpps,application_evidencelibrary,component_ping,isproduction_true,environment_production,performance_hub_dev"
  probefilters             = "region:EU"
  #integrationids           = [114774]
}

resource "pingdom_check" "justicedata-pingdom" {
  type                     = "http"
  name                     = "evidencelibraryapi - production - cloud-platform"
  host                     = "evidencelibrary-api-test.apps.live-1.cloud-platform.service.justice.gov.uk/health"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_hmpps,application_evidencelibrary,component_ping,isproduction_true,environment_production,performance_hub_dev"
  probefilters             = "region:EU"
  #integrationids           = [114774]
}