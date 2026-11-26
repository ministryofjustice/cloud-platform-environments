resource "kubernetes_manifest" "github_app_secret" {
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
            "key" = "app/github-app"
          }
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "entra_app_secret" {
  manifest = {
    "apiVersion" = "external-secrets.io/v1"
    "kind"       = "ExternalSecret"
    "metadata" = {
      "namespace" = var.namespace
      "name"      = "entra-app"
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
        "name" = "entra-app"
      }
      "dataFrom" = [
        {
          "extract" = {
            "key" = "app/entra-app"
          }
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "notify_secret" {
  manifest = {
    "apiVersion" = "external-secrets.io/v1"
    "kind"       = "ExternalSecret"
    "metadata" = {
      "namespace" = var.namespace
      "name"      = "notify"
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
        "name" = "notify"
      }
      "dataFrom" = [
        {
          "extract" = {
            "key" = "app/notify"
          }
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "sentry_secret" {
  manifest = {
    "apiVersion" = "external-secrets.io/v1"
    "kind"       = "ExternalSecret"
    "metadata" = {
      "namespace" = var.namespace
      "name"      = "sentry"
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
        "name" = "sentry"
      }
      "dataFrom" = [
        {
          "extract" = {
            "key" = "app/sentry"
          }
        }
      ]
    }
  }
}
