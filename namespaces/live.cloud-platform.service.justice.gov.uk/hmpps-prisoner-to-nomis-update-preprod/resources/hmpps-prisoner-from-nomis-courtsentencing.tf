resource "kubernetes_secret" "prisoner_from_nomis_courtsentencing_secret" {
  metadata {
    name      = "prisoner-from-nomis-courtsentencing-queue"
    namespace = var.namespace
  }

  data = {
    sqs_queue_name = "syscon-devs-${var.environment}-prisoner_from_nomis_courtsentencing_queue"
  }
}

