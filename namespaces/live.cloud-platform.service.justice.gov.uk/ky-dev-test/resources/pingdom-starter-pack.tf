data "dns_a_record_set" "helloworld" {
  host = var.helloworld_host_name
}

resource "pingdom_check" "helloworld" {
  type                     = "https"
  name                     = "ky-dev-test-helloworld"
  host                     = var.helloworld_host_name
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 3
  notifyagainevery         = 0
  encryption               = true
  port                     = 443
  tags                     = "businessunit_platforms,application_prometheus,component_healthcheck,isproduction_false,environment_dev,infrastructuresupport_platforms"
  probefilters             = "region:EU"
}

resource "pingdom_check" "helloworld_ips" {
  for_each                 = toset(data.dns_a_record_set.helloworld.addrs)
  type                     = "https"
  name                     = "ky-dev-test-${var.helloworld_host_name} : ${each.value}"
  host                     = each.value
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 3
  notifyagainevery         = 0
  encryption               = false
  port                     = 443
  tags                     = "businessunit_platforms,application_prometheus,component_healthcheck,isproduction_false,environment_dev,infrastructuresupport_platforms"
  probefilters             = "region:EU"
  requestheaders           = { "Host" = var.helloworld_host_name }
}