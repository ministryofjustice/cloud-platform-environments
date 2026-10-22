module "hmpps_egress_controls" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-egress-controls?ref=0.0.12"

  enable_envoy_setup     = true
  enable_egress_controls = false

  namespace = var.namespace
  vpc_name  = var.vpc_name

  # See https://github.com/DependencyTrack/dependency-track/blob/main/apiserver/src/main/resources/services.bom.json
  # for DependencyTrack's published external hosts

  envoy_extra_allowed_hosts_exact = [
    "api.github.com",
    "api.nuget.org",
    "api.snyk.io",
    "channels.nixos.org",
    "epss.empiricalsecurity.com",
    "fastapi.metacpan.org",
    "hackage.haskell.org",
    "hex.pm",
    "index.crates.io",
    "maven.google.com",
    "metrics.dependencytrack.org",
    "nvd.nist.gov",
    "ossindex.sonatype.org",
    "osv-vulnerabilities.storage.googleapis.com",
    "packages.atlassian.com",
    "proxy.golang.org",
    "pypi.org",
    "registry.npmjs.org",
    "repo.clojars.org",
    "repo.packagist.org",
    "repo1.maven.org",
    "repository.jboss.org",
    "rubygems.org",
    "vulndb.cyberriskanalytics.com",
  ]

  envoy_extra_allowed_hosts_suffixes = [
    "service.justice.gov.uk",
    "svc.cluster.local",
  ]
}
