provider "pingdom" {
}

resource "pingdom_check" "vcms-pingdom-check-poc" {
  type                     = "http"
  name                     = "vcms-http-check"
  host                     = "vcms-poc-app.apps.live.cloud-platform.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/login"
  encryption               = true
  port                     = 443
  # tags as per https://technical-guidance.service.justice.gov.uk/documentation/standards/documenting-infrastructure-owners.html#tags-you-should-use
  tags           = "businessunit_HMPPS,application_vcms,environment-name_poc,component_healthcheck,isproduction_false,owner_platforms"
  probefilters   = "region:EU"
  integrationids = [123923]
}
