resource "kubernetes_secret" "prisoner_from_nomis_courtsentencing_secret" {
  metadata {
    name      = "prisoner_from_nomis_courtsentencing_queue"
    namespace = var.namespace
  }

  data = {
    sqs_queue_name = "syscon-devs-${var.environment}-prisoner_from_nomis_courtsentencing_queue"
  }
}

