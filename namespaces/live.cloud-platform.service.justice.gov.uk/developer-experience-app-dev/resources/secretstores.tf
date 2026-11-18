resource "kubernetes_manifest" "developer_experience_secret_store" {
  manifest = {
    "apiVersion" = "external-secrets.io/v1"
    "kind"       = "SecretStore"
    "metadata" = {
      "namespace" = var.namespace
      "name"      = "developer-experience-development"
      "labels" = {
        "managed/by" : "terraform"
      }
    }
    "spec" = {
      "provider" = {
        "aws" : {
          "service" : "SecretsManager"
          "region" : data.aws_region.current.name
          "auth" : {
            "jwt" : {
              "serviceAccountRef" : {
                "name" : kubernetes_service_account_v1.eso.metadata[0].name
              }
            }
          }
        }
      }
    }
  }
}