module "example_team_ec_cluster" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=6.0.0"
  vpc_name               = var.vpc_name
  team_name              = var.team_name
  namespace              = var.namespace
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support

  engine_version       = "7.0"
  parameter_group_name = "default.redis7"
  node_type            = "cache.t4g.micro"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "example_team_ec_cluster" {
  metadata {
    name      = "example-team-ec-cluster-output"
    namespace = var.namespace
  }

  data = {
    primary_endpoint_address = module.example_team_ec_cluster.primary_endpoint_address
    member_clusters          = jsonencode(module.example_team_ec_cluster.member_clusters)
    auth_token               = module.example_team_ec_cluster.auth_token
    access_key_id            = module.example_team_ec_cluster.access_key_id
    secret_access_key        = module.example_team_ec_cluster.secret_access_key
    replication_group_id     = module.example_team_ec_cluster.replication_group_id
  }
}
