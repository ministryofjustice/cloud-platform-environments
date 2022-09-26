resource "pingdom_check" "cloud-platform-prometheus-eks-live-2" {
  type                     = "http"
  name                     = "cloud-platform monitoring Prometheus eks-live-2"
  host                     = "prometheus.live-2.cloud-platform.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/-/healthy"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_platforms,application_prometheus,component_healthcheck,isproduction_true,environment_prod,infrastructuresupport_platforms"
  probefilters             = "region:EU"
  integrationids           = [117363]
}

resource "pingdom_check" "cloud-platform-grafana-eks-live-2" {
  type                     = "http"
  name                     = "cloud-platform monitoring Alert Manager eks-live-2"
  host                     = "alertmanager.live-2.cloud-platform.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 5
  notifyagainevery         = 0
  url                      = "/-/healthy"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_platforms,application_prometheus,component_healthcheck,isproduction_true,environment_prod,infrastructuresupport_platforms"
  probefilters             = "region:EU"
  integrationids           = [90339]
}

resource "pingdom_check" "cloud-platform-alertmanager-eks-live-2" {
  type                     = "http"
  name                     = "cloud-platform monitoring Grafana eks-live-2"
  host                     = "grafana.live-2.cloud-platform.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 5
  notifyagainevery         = 0
  url                      = "/"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_platforms,application_prometheus,component_healthcheck,isproduction_true,environment_prod,infrastructuresupport_platforms"
  probefilters             = "region:EU"
  integrationids           = [90339]
}

resource "pingdom_check" "cloud-platform-kuberos-eks-live-2" {
  type                     = "http"
  name                     = "cloud-platform Kuberos eks-live-2"
  host                     = "login.live-2.cloud-platform.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 5
  notifyagainevery         = 0
  url                      = "/"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_platforms,application_prometheus,component_healthcheck,isproduction_false,environment_dev,infrastructuresupport_platforms"
  probefilters             = "region:EU"
  integrationids           = [90339]
}

