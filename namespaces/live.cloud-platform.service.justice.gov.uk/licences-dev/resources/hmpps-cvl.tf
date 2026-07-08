resource "kubernetes_secret" "hmpps_cvl" {
  metadata {
    name      = "sqs-hmpps-hdc-api-secret"
    namespace = "create-and-vary-a-licence-api-dev"
  }

  data = {
    sqs_queue_url   = module.hmpps_hdc_api_queue.sqs_id
    sqs_queue_arn   = module.hmpps_hdc_api_queue.sqs_arn
    sqs_queue_name  = module.hmpps_hdc_api_queue.sqs_name
    irsa_policy_arn = module.hmpps_hdc_api_queue.irsa_policy_arn
  }
}
