resource "pingdom_check" "laa-crime-application-tracking-service-test" {
  type                     = "http"
  name                     = "LAA Crime Application Tracking Service - Test"
  host                     = "laa-crime-application-tracking-service-test.apps.live.cloud-platform.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 3
  notifyagainevery         = 0
  url                      = "/actuator/health"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_laa,application_laa-crime-application-tracking-service,component_ping,isproduction_false,environment_test,owner_laa-crime-apps-team"
  probefilters             = "region:EU"
  integrationids           = [121160]
}