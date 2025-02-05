repository {
  github {
    baseuri     = ""
    uploaduri   = ""
    timeout     = "1m"
    owner       = "ministryofjustice"
    repo        = "cloud-platform-environments"
    maxComments = 50
  }
}

parser {
  include = ["namespaces/live.cloud-platform.service.justice.gov.uk/*/*prometheus*.yaml", "namespaces/live.cloud-platform.service.justice.gov.uk/*/*prometheus*.yml", "namespaces/live-2.cloud-platform.service.justice.gov.uk/*/*prometheus*.yaml", "namespaces/live-2.cloud-platform.service.justice.gov.uk/*/*prometheus*.yml"]
  relaxed = [".*"]
}