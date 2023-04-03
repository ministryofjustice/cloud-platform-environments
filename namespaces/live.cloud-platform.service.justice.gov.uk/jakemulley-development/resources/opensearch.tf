# module "opensearch_all" {
#   source = "github.com/ministryofjustice/cloud-platform-terraform-opensearch?ref=first-pass"

#   vpc_name         = var.vpc_name
#   eks_cluster_name = var.eks_cluster_name
#   engine_version   = "OpenSearch_1.0"

#   # prod
#   cluster_config = {
#     dedicated_master_enabled = true
#     dedicated_master_count   = 3
#     dedicated_master_type    = "c6g.large.search"

#     instance_count = 3
#     instance_type  = "c6g.large.search"

#     warm_enabled = true
#     warm_count   = 3
#     warm_type    = "ultrawarm1.large.search"
#   }

#   business_unit          = var.business_unit
#   application            = var.application
#   is_production          = var.is_production
#   team_name              = var.team_name
#   namespace              = var.namespace
#   environment_name       = var.environment
#   infrastructure_support = var.infrastructure_support
# }

# module "opensearch_production" {
#   source = "github.com/ministryofjustice/cloud-platform-terraform-opensearch?ref=first-pass"

#   vpc_name         = var.vpc_name
#   eks_cluster_name = var.eks_cluster_name
#   engine_version   = "OpenSearch_1.0"

#   # prod
#   cluster_config = {
#     instance_count = 3
#     instance_type  = "t3.medium.search"
#   }

#   business_unit          = var.business_unit
#   application            = var.application
#   is_production          = var.is_production
#   team_name              = var.team_name
#   namespace              = var.namespace
#   environment_name       = var.environment
#   infrastructure_support = var.infrastructure_support
# }

# module "opensearch_nonproduction" {
#   source = "github.com/ministryofjustice/cloud-platform-terraform-opensearch?ref=first-pass"

#   vpc_name         = var.vpc_name
#   eks_cluster_name = var.eks_cluster_name
#   engine_version   = "OpenSearch_1.0"

#   # non-prod
#   cluster_config = {
#     instance_count = 1
#     instance_type  = "t3.medium.search"
#   }

#   business_unit          = var.business_unit
#   application            = var.application
#   is_production          = var.is_production
#   team_name              = var.team_name
#   namespace              = var.namespace
#   environment_name       = var.environment
#   infrastructure_support = var.infrastructure_support
# }
