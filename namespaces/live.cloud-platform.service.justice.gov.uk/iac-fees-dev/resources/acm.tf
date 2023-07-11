data "kubernetes_secret" "zone_id" {
  metadata {
    name      = "route53-justice-zone-output"
    namespace = var.base_domain_route53_namespace
  }
}
