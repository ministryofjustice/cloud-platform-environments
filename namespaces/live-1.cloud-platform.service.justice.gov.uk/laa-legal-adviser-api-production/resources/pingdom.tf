provider "pingdom" {}
terraform {
  backend "s3" {}
}

resource "pingdom_check" "laa-legal-adviser-api-ping-check" {
   type                     = "http"
   name                     = "Laa Legal Adviser API - LAALAA - ping check"
   host                     = "laa-legal-adviser-api-production.cloud-platform.service.justice.gov.uk"
   resolution               = 1
   notifywhenbackup         = true
   sendnotificationwhendown = 6
   notifyagainevery         = 0
   url                      = "/ping.json"
   encryption               = true
   port                     = 443
   tags                     = "businessunit_${var.business-unit},application_${var.application},component_ping,isproduction_${var.is-production},environment_${var.environment-name},infrastructuresupport_${var.application}"
   probefilters             = "region:EU"
   publicreport             = "true"
 }

resource "pingdom_check" "laa-legal-adviser-api-healthcheck" {
   type                     = "http"
   name                     = "Laa Legal Adviser API - LAALAA - healthcheck"
   host                     = "laa-legal-adviser-api-production.cloud-platform.service.justice.gov.uk"
   resolution               = 1
   notifywhenbackup         = true
   sendnotificationwhendown = 6
   notifyagainevery         = 0
   url                      = "/healthcheck.json"
   encryption               = true
   port                     = 443
   tags                     = "businessunit_${var.business-unit},application_${var.application},component_ping,isproduction_${var.is-production},environment_${var.environment-name},infrastructuresupport_${var.application}"
   probefilters             = "region:EU"
   publicreport             = "true"
 }
