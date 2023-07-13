provider "pingdom" {
}

# Integration IDs
# 130487 = #prison-education-alerts

resource "pingdom_check" "hmpps-get-ready-for-work-production-check" {
  type                     = "http"
  name                     = "HMPPS - Get someone ready to work"
  host                     = "health-kick.prison.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/https/get-ready-for-work.hmpps.service.justice.gov.uk"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_hmpps,application_get-ready-for-work,component_front-end,isproduction_true,environment_prod"
  probefilters             = "region:EU"
  integrationids           = [130487]
}

resource "pingdom_check" "hmpps-education-employment-api-check" {
  type                     = "http"
  name                     = "HMPPS - Education Employment API"
  host                     = "health-kick.prison.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/https/education-employment-api.hmpps.service.justice.gov.uk"
  encryption               = true
  port                     = 443
  tags                     = "businessunit_hmpps,application_education-employment-api,component_api,isproduction_true,environment_prod"
  probefilters             = "region:EU"
  integrationids           = [130487]
}

resource "pingdom_check" "hmpps-ciag-careers-induction-ui-production-check" {
	type                     = "http"
	name                     = "HMPPS - CIAG Induction"
	host                     = "health-kick.prison.service.justice.gov.uk"
	resolution               = 1
	notifywhenbackup         = true
	sendnotificationwhendown = 6
	notifyagainevery         = 0
	url                      = "/https/ciag-induction.hmpps.service.justice.gov.uk"
	encryption               = true
	port                     = 443
	tags                     = "businessunit_hmpps,application_ciag-careers-induction,component_front-end,isproduction_true,environment_prod"
	probefilters             = "region:EU"
	integrationids           = [130487]
}

resource "pingdom_check" "hmpps-ciag-careers-induction-api-check" {
	type                     = "http"
	name                     = "HMPPS - CIAG Induction API"
	host                     = "health-kick.prison.service.justice.gov.uk"
	resolution               = 1
	notifywhenbackup         = true
	sendnotificationwhendown = 6
	notifyagainevery         = 0
	url                      = "/https/ciag-induction-api.hmpps.service.justice.gov.uk"
	encryption               = true
	port                     = 443
	tags                     = "businessunit_hmpps,application_ciag-careers-induction-api,component_api,isproduction_true,environment_prod"
	probefilters             = "region:EU"
	integrationids           = [130487]
}
