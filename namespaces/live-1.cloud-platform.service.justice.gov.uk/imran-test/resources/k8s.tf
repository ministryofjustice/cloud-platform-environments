locals {
  team-resources = "0.1.0"
}

resource "kubernetes_namespace" "team-resources" {
  metadata {
    name = "team-resources"

    labels = {
      "name"                                           = "team-resources"
      "cloud-platform.justice.gov.uk/environment-name" = "dev"
      "cloud-platform.justice.gov.uk/is-production"    = "false"
    }

    annotations = {
      "cloud-platform.justice.gov.uk/application"                   = "helm-test"
      "cloud-platform.justice.gov.uk/business-unit"                 = "cloud-platform"
      "cloud-platform.justice.gov.uk/owner"                         = "Cloud Platform: platforms@digital.justice.gov.uk"
      "cloud-platform.justice.gov.uk/source-code"                   = "https://github.com/ministryofjustice/cloud-platform-infrastructure"
    }
  }
}

data "helm_repository" "cloud-platform" {
  name = "cloud-platform"
  url  = "https://ministryofjustice.github.io/cloud-platform-helm-charts"
}

resource "helm_release" "cloud-platform" {
  name          = "team-resources"
  chart         = "cloud-platform"
  repository    = data.helm_repository.cloud-platform.metadata[0].name
  namespace     = "team-resources"
  version       = local.team-resources
  recreate_pods = true

  values = [
    <<EOF
        namespace: team-resources
        rds.secret: "postgres://${module.rds-instance.database_username}:${module.rds-instance.database_password}@${module.rds-instance.rds_instance_endpoint}/${module.rds-instance.database_name}"
    EOF
    ,
  ]

  depends_on = [
    kubernetes_namespace.team-resources,
  ]
}
