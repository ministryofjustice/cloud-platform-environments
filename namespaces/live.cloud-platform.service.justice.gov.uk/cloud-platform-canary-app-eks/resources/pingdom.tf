resource "pingdom_check" "cloud-platform-canary" {
  type                     = "http"
  name                     = "cloud-platform monitoring canary"
  host                     = "canary.apps.live.cloud-platform.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 3
  notifyagainevery         = 0
  url                      = "/healthz"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_platforms,application_prometheus,component_healthcheck,isproduction_false,environment_dev,infrastructuresupport_platforms"
  probefilters             = "region:EU"
  integrationids           = [90334]
}

