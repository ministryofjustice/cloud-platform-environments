resource "kubernetes_manifest" "github_app" {
  manifest = {
    "apiVersion" = "external-secrets.io/v1"
    "kind"       = "ExternalSecret"
    "metadata" = {
      "namespace" = var.namespace
      "name"      = "github-app"
      "labels" = {
        "managed/by" : "terraform"
      }
    }
    "spec" = {
      "refreshInterval" = "5m"
      "secretStoreRef" = {
        "kind" = "SecretStore"
        "name" = kubernetes_manifest.developer_experience_secret_store.manifest["metadata"]["name"]
      }
      "target" = {
        "name" = "github-app"
      }
      "dataFrom" = [
        {
          "extract" = {
            "key" = "github-sts/github-app"
          }
        }
      ]
    }
  }
}
