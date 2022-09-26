
data "dns_a_record_set" "canary" {
  host = var.host_name
}

data "dns_a_record_set" "canary_modsec" {
  host = "modsec-${var.host_name}"
}

resource "pingdom_check" "cloud-platform-canary" {
  type                     = "http"
  name                     = "cloud-platform monitoring canary in live-2"
  host                     = var.host_name
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 3
  notifyagainevery         = 0
  url                      = "/healthz"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_platforms,application_prometheus,component_healthcheck,isproduction_false,environment_dev,infrastructuresupport_platforms"
  probefilters             = "region:EU"
  integrationids           = [117363]
}

resource "pingdom_check" "cloud-platform-ips" {
  for_each                 = toset(data.dns_a_record_set.canary.addrs)
  type                     = "http"
  name                     = "${var.host_name} : ${each.value}"
  host                     = each.value
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 3
  notifyagainevery         = 0
  url                      = "/healthz"
  encryption               = false
  port                     = 80
  tags                     = "businessunit_platforms,application_prometheus,component_healthcheck,isproduction_false,environment_dev,infrastructuresupport_platforms"
  probefilters             = "region:EU"
  requestheaders           = { "Host" = var.host_name }
  integrationids           = [117363]

  depends_on = [helm_release.cloud_platform_modsec_canary]
}

resource "pingdom_check" "cloud-platform-modsec-ips" {
  for_each                 = toset(data.dns_a_record_set.canary_modsec.addrs)
  type                     = "http"
  name                     = "modsec-${var.host_name} : ${each.value}"
  host                     = each.value
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 3
  notifyagainevery         = 0
  url                      = "/healthz"
  encryption               = false
  port                     = 80
  tags                     = "businessunit_platforms,application_prometheus,component_healthcheck,isproduction_false,environment_dev,infrastructuresupport_platforms"
  probefilters             = "region:EU"
  requestheaders           = { "Host" = "modsec-${var.host_name}" }
  integrationids           = [117363]

  depends_on = [helm_release.cloud_platform_modsec_canary]
}
