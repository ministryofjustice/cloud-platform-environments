
resource "pingdom_check" "test-project" {
  type                     = "http"
  name                     = "Integration - test-project"
  host                     = "health-kick.prison.service.justice.gov.uk"
  port                     = 443
  url                      = "/https/test-project-dev.hmpps.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  encryption               = true
  tags                     = "probation-integration,hmpps,cloudplatform-managed"
  probefilters             = "region:EU"
  integrationids           = [120233] # probation-integration-notifications
}
