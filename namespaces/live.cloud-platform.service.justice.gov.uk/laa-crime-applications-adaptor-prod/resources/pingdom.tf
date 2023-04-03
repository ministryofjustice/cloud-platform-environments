resource "pingdom_check" "laa-crime-applications-adaptor-prod" {
  type                     = "http"
  name                     = "LAA Crime Applications Adaptor - Prod"
  host                     = "laa-crime-applications-adaptor-prod.apps.live.cloud-platform.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 3
  notifyagainevery         = 0
  url                      = "/actuator/health"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_laa,application_laa-crime-applications-adaptor,component_ping,isproduction_true,environment_prod,owner_laa-crime-apps-team"
  probefilters             = "region:EU"
  integrationids           = [121160]
}