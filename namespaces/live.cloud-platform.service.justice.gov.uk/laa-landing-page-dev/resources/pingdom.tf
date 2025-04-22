provider "pingdom" {
}

resource "pingdom_check" "laa-landing-page-dev" {
  type                     = "http"
  name                     = "laa-landing-page - dev - cloud-platform"
  host                     = "laa-landing-page-dev.apps.live.cloud-platform.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 7
  notifyagainevery         = 0
  url                      = "/"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_LAA,application_landing-page,is-production_false,component_healthcheck,environment_dev,owner_laa-portal-stabilisation-tech:ben.ashton@justice.gov.uk"
  probefilters             = "region:EU"
  integrationids           = [142729]
}

