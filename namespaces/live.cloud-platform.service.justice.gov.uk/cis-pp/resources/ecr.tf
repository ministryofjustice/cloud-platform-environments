/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
locals {
  cache_rule = {
    rulePriority = 1
    description  = "Retain service build caches"

    selection = {
      tagStatus      = "tagged"
      tagPatternList = ["*-buildcache"]
      countType      = "imageCountMoreThan"
      countNumber    = length(var.services)
    }

    action = {
      type = "expire"
    }
  }

  untagged_rule = {
    rulePriority = 2
    description  = "Expire untagged images older than 14 days"

    selection = {
      tagStatus   = "untagged"
      countType   = "sinceImagePushed"
      countUnit   = "days"
      countNumber = 14
    }

    action = {
      type = "expire"
    }
  }

  service_rules = [
    for index, service in var.services : {
      rulePriority = index + 3
      description  = "Retain ${service} images and cache"

      selection = {
        tagStatus      = "tagged"
        tagPatternList = ["${service}-*"]
        countType      = "imageCountMoreThan"
        countNumber    = 3
      }

      action = {
        type = "expire"
      }
    }
  ]

  tagged_images_catch_all_rule = {
    rulePriority = length(var.services) + 3
    description  = "Retain the 10 newest tagged images not covered by other rules"

    selection = {
      tagStatus   = "tagged"
      countType   = "imageCountMoreThan"
      countNumber = 46
    }

    action = {
      type = "expire"
    }
  }

  ecr_lifecycle_policy = jsonencode({
    rules = concat(
      [local.cache_rule, local.untagged_rule],
      local.service_rules,
      [local.tagged_images_catch_all_rule],
    )
  })
}

module "ecr" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=8.0.1"

  # Repository configuration
  repo_name = var.namespace

  # OpenID Connect configuration
  oidc_providers      = ["github"]
  github_repositories = [var.github_repository]
  github_environments = [var.github_environment]

  lifecycle_policy = local.ecr_lifecycle_policy

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the container repository
  namespace              = var.namespace # also used for creating a Kubernetes ConfigMap
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  # If you want to assign AWS permissions to a k8s pod in your namespace - ie service pod for read only queries,
  # uncomment below:

  #enable_irsa = true
}
