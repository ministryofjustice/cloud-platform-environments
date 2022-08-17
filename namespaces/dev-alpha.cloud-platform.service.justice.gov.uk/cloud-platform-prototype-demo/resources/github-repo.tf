
# This module creates files to build docker image and 
# continuous deployment (CD) workflow in prototype github repo.

module "github-prototype" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-github-prototype?ref=0.1.1"

  namespace = var.namespace
}
