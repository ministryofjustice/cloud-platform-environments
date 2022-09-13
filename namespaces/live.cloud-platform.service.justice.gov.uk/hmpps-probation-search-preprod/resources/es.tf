module "probation_search_elasticsearch" {
  source                          = "github.com/ministryofjustice/cloud-platform-terraform-elasticsearch?ref=out-es"
  cluster_name                    = var.cluster_name
  application                     = var.application
  business-unit                   = var.business_unit
  environment-name                = var.environment
  infrastructure-support          = var.infrastructure_support
  is-production                   = var.is_production
  team_name                       = "pi"
  elasticsearch-domain            = "probation-search"
  aws_es_proxy_service_name       = "es-proxy"
  encryption_at_rest              = true
  node_to_node_encryption_enabled = true
  namespace                       = var.namespace
  elasticsearch_version           = "7.10"
  dedicated_master_enabled        = true
  aws-es-proxy-replica-count      = 3
  instance_type                   = "m5.large.elasticsearch"
  ebs_volume_size                 = 30
}

provider "elasticsearch" {
  url         = "https://${module.probation_search_elasticsearch.aws_endpoint}"
  aws_profile = "moj-cp"
}

resource "elasticsearch_opensearch_ism_policy" "ism-policy" {
  policy_id = "hot-warm-cold-delete"
  body      = data.template_file.ism_policy.rendered
}

data "template_file" "ism_policy" {
  template = trimspace(templatefile("es/es.json.tpl", {

    timestamp_field   = var.timestamp_field
    warm_transition   = var.warm_transition
    cold_transition   = var.cold_transition
    delete_transition = var.delete_transition
    index_pattern     = jsonencode(var.index_pattern)
  }))
}