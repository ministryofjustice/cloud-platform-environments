
# This module creates files to build docker image and 
# continuous deployment (CD) workflow in prototype github repo.

module "github-prototype" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-github-prototype?ref=0.1.1"

  prototype_create_deployment_file = false
  prototype_create_docker_ignore_file = false
  prototype_create_dockerfile = false
  prototype_create_github_workflow = false
  prototype_create_start_sh = false

  namespace = var.namespace
}
