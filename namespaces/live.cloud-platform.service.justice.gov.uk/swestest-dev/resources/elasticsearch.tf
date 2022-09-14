/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "sw_test_es" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticsearch?ref=ism-policy-tf"
  cluster_name           = var.cluster_name
  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  namespace              = var.namespace

  elasticsearch-domain = "test-es"

  # change the elasticsearch version as you see fit.
  elasticsearch_version = "7.10"

  # This will enable creation of manual snapshot in s3 repo, provide the "s3 bucket arn" to create snapshot in s3.
  # s3_manual_snapshot_repository = "s3-bucket-arn"

  instance_count           = 5
  instance_type            = "r6g.large.elasticsearch"
  zone_awareness_enabled   = "true"
  availability_zone_count  = 3
  ebs_volume_size          = 20
  ebs_volume_type          = "gp3"
  ebs_iops                 = 3000
  dedicated_master_enabled = "true"
  dedicated_master_type    = "m6g.large.elasticsearch"
  warm_enabled             = "true"
  cold_enabled             = "true"
  # this is used by the index policies for transition to warm/cold
  timestamp_field = "last_updated"
  index_pattern   = "test_data*"
}

/*
 *There is no support for ISM in tf yet, the index pattern and policy per the output below must be created in Kibana manually
 *
 */
output "ism_policy" {
  value = module.sw_test_es.ism_policy
}

output "es_endpoint" {
    value = module.sw_test_es.es_endpoint
}

provider "elasticsearch" {
  url                         = "https://${module.sw_test_es.es_endpoint}"
  aws_profile                 = "moj-cp"
  aws_region                  = "eu-west-2"
  aws_assume_role_arn         = "arn:aws:iam::754256621582:role/cloud-platform-68b7eb77defb5024-irsa"
  insecure    = true
  healthcheck = false
}

resource "elasticsearch_opensearch_ism_policy" "ism-policy" {
  policy_id = "hot-warm-cold-delete"
  body      = data.template_file.ism_policy.rendered
}

data "template_file" "ism_policy" {
  template = trimspace(templatefile("ism/ism_template.json.tpl", {

    timestamp_field   = var.timestamp_field
    warm_transition   = var.warm_transition
    cold_transition   = var.cold_transition
    delete_transition = var.delete_transition
    index_pattern     = jsonencode(var.index_pattern)
  }))
}
