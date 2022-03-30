
# This module creates files to build docker image and 
# continuous deployment (CD) workflow in prototype github repo.

module "github-design-history" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-github-design-history?ref=main"

  namespace = var.namespace
}
