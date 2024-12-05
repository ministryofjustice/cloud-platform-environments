resource "pingdom_check" "laa-crime-apply-mock-api-test" {
  type                     = "http"
  name                     = "LAA Crime Apply Mock API - TEST"
  host                     = "laa-crime-apply-mock-api-test.apps.live.cloud-platform.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 3
  notifyagainevery         = 0
  url                      = "/api/message"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_laa,application_laa-crime-apply-mock-api,component_ping,isproduction_false,environment_test,owner_laa-crime-apps-team"
  probefilters             = "region:EU"
  integrationids           = [121160]
}