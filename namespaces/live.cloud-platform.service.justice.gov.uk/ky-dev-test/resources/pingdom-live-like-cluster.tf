provider "pingdom" {
}

resource "pingdom_check" "helloworld-app-starter-pack-2" {
  type                     = "http"
  name                     = "cp-live-like-helloworld-app-starter-pack-2"
  host                     = "helloworld-app-starter-pack-2.apps.cp-1410-0921.cloud-platform.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_platforms,application_prometheus,component_healthcheck,isproduction_true,environment_uat,infrastructuresupport_platforms"
  probefilters             = "region:EU"
  integrationids           = [149567]
}

resource "pingdom_check" "helloworld-app-starter-pack-12" {
  type                     = "http"
  name                     = "cp-live-like-helloworld-app-starter-pack-12"
  host                     = "helloworld-app-starter-pack-12.apps.cp-1410-0921.cloud-platform.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_platforms,application_prometheus,component_healthcheck,isproduction_true,environment_uat,infrastructuresupport_platforms"
  probefilters             = "region:EU"
  integrationids           = [149567]
}

resource "pingdom_check" "multi-container-app-starter-pack-22" {
  type                     = "http"
  name                     = "cp-live-like-multi-container-app-starter-pack-22"
  host                     = "multi-container-app-starter-pack-22.apps.cp-1410-0921.cloud-platform.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_platforms,application_prometheus,component_healthcheck,isproduction_true,environment_uat,infrastructuresupport_platforms"
  probefilters             = "region:EU"
  integrationids           = [149567]
}

resource "pingdom_check" "multi-container-app-starter-pack-33" {
  type                     = "http"
  name                     = "cp-live-like-multi-container-app-starter-pack-33"
  host                     = "multi-container-app-starter-pack-33.apps.cp-1410-0921.cloud-platform.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_platforms,application_prometheus,component_healthcheck,isproduction_true,environment_uat,infrastructuresupport_platforms"
  probefilters             = "region:EU"
  integrationids           = [149567]
}

resource "pingdom_check" "grafana" {
  type                     = "http"
  name                     = "cp-live-like-grafana"
  host                     = "grafana.cp-1410-0921.cloud-platform.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_platforms,application_prometheus,component_healthcheck,isproduction_true,environment_uat,infrastructuresupport_platforms"
  probefilters             = "region:EU"
  integrationids           = [149567]
}

resource "pingdom_check" "prometheus" {
  type                     = "http"
  name                     = "cp-live-like-prometheus"
  host                     = "prometheus.cp-1410-0921.cloud-platform.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/-/healthy"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_platforms,application_prometheus,component_healthcheck,isproduction_true,environment_uat,infrastructuresupport_platforms"
  probefilters             = "region:EU"
  integrationids           = [149567]
}