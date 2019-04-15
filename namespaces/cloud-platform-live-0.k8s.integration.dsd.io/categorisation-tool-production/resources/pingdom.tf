
resource "pingdom_check" "cloud-platform-prometheus-live-0-healthcheck" {
  type                     = "http"
  name                     = "Digital Cat Tool - Production - cloud-platform - Healthcheck"
  host                     = "categorisation-tool.apps.cloud-platform-live-0.k8s.integration.dsd.io"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/health"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_platforms,application_prometheus,component_healthcheck,isproduction_true,environment_prod,infrastructuresupport_platforms"
  probefilters             = "region:EU"
  publicreport             = "true"
  integrationids           = [91037]
}