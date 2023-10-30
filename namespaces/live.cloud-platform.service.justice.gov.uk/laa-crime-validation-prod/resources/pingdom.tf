resource "pingdom_check" "laa-crime-validation-prod" {
  type                     = "http"
  name                     = "LAA Crime Validation - Production"
  host                     = "laa-crime-validation-prod.apps.live.cloud-platform.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 3
  notifyagainevery         = 0
  url                      = "/actuator/health"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_laa,application_laa-crime-validation,component_ping,isproduction_true,environment_prod,owner_laa-crime-apps-team"
  probefilters             = "region:EU"
  integrationids           = [121160]
}