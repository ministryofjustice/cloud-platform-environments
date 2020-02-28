provider "pingdom" {
}

# Integration IDs
# 100321 = #form-builder-alerts

resource "pingdom_check" "form-name"" {
  type                     = "http"
  name                     = "Form Builder - ${var.form_name}"
  host                     = "${var.host}"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/ping.json"
  encryption               = true
  port                     = 443
  tags                     = ""
  probefilters             = "region:EU"
  integrationids           = [100321]
}

