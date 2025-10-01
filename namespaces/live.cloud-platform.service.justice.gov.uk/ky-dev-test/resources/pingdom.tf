data "dns_a_record_set" "canary" {
  host = var.default_host_name
}

data "dns_a_record_set" "canary_modsec" {
  host = var.modsec_host_name
}

resource "pingdom_check" "cloud-platform-default-ingress" {
  type                     = "http"
  name                     = "ky-dev-test-ing-check-default"
  host                     = var.default_host_name
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 3
  notifyagainevery         = 0
  url                      = "/healthz"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_platforms,application_prometheus,component_healthcheck,isproduction_false,environment_dev,infrastructuresupport_platforms"
  probefilters             = "region:EU"
}

resource "pingdom_check" "cloud-platform-modsec-ingress" {
  type                     = "http"
  name                     = "ky-dev-test-ing-check-modsec"
  host                     = var.modsec_host_name
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 3
  notifyagainevery         = 0
  url                      = "/healthz"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_platforms,application_prometheus,component_healthcheck,isproduction_false,environment_dev,infrastructuresupport_platforms"
  probefilters             = "region:EU"
}


resource "pingdom_check" "cloud-platform-default-ips" {
  for_each                 = toset(data.dns_a_record_set.canary.addrs)
  type                     = "http"
  name                     = "ky-dev-test-${var.default_host_name} : ${each.value}"
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
  requestheaders           = { "Host" = var.default_host_name }
}

resource "pingdom_check" "cloud-platform-modsec-ips" {
  for_each                 = toset(data.dns_a_record_set.canary_modsec.addrs)
  type                     = "http"
  name                     = "ky-dev-test-${var.modsec_host_name} : ${each.value}"
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
  requestheaders           = { "Host" = var.modsec_host_name }
}