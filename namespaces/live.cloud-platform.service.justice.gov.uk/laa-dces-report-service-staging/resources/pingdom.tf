resource "pingdom_check" "laa-dces-report-service-staging" {
  type                     = "http"
  name                     = "LAA DCES Reports Service - Staging"
  host                     = "laa-dces-report-service-staging.apps.live.cloud-platform.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 3
  notifyagainevery         = 0
  url                      = "/actuator/health"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_laa,application_laa-dces-report-service,component_ping,isproduction_false,environment_staging,owner_laa-crime-apps-team"
  probefilters             = "region:EU"
  integrationids           = [121160]
}