resource "pingdom_check" "laa-dces-report-service-uat" {
  type                     = "http"
  name                     = "LAA DCES Reports Service - UAT"
  host                     = "laa-dces-report-service-uat.apps.live.cloud-platform.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 3
  notifyagainevery         = 0
  url                      = "/actuator/health"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_laa,application_laa-dces-report-service,component_ping,isproduction_false,environment_uat,owner_laa-dces-team"
  probefilters             = "region:EU"
  integrationids           = [121160]
}