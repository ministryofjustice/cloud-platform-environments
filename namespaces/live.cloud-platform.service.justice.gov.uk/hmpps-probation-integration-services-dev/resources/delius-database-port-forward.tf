resource "kubernetes_deployment" "delius_database_port_forward" {
  metadata {
    name      = "delius-database"
    namespace = var.namespace
    labels = {
      app       = "delius-database"
      namespace = var.namespace
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app       = "delius-database"
        namespace = var.namespace
      }
    }
    template {
      metadata {
        labels = {
          app       = "delius-database"
          namespace = var.namespace
        }
      }
      spec {
        container {
          name  = "delius-database"
          image = "ministryofjustice/port-forward"

          port {
            container_port = 1521
          }

          env {
            name = "REMOTE_HOST"
            value_from {
              secret_key_ref {
                key  = "DB_HOST"
                name = "common"
              }
            }
          }
          env {
            name  = "LOCAL_PORT"
            value = "1521"
          }
          env {
            name  = "REMOTE_PORT"
            value = "1521"
          }
        }
      }
    }
  }
}
