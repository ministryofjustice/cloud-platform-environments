/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "ecr_credentials" {
  source    = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=5.2.0"
  team_name = var.team_name
  repo_name = "laa-estimate-financial-eligibility-for-legal-aid-ecr"

  # enable the oidc implementation for CircleCI
  oidc_providers = ["circleci"]

  # specify which GitHub repository your CircleCI job runs from
  github_repositories = ["laa-estimate-financial-eligibility-for-legal-aid"]

  # set your namespace name to create a ConfigMap of credentials you need in CircleCI
  namespace = var.namespace

  /*
    By default scan_on_push is set to true. When this is enabled then all images pushed to the repo are scanned for any security
    / software vulnerabilities in your image and the results can be viewed in the console. For further details, please see:
    https://docs.aws.amazon.com/AmazonECR/latest/userguide/image-scanning.html
    To disable 'scan_on_push', set it to false as below:
  scan_on_push = "false"
  */

  # list of github environments, to create the ECR secrets as environment secrets
  # https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment#environment-secrets
  # github_environments = ["my-environment"]


  # Lifecycle_policy provides a way to automate the cleaning up of your container images by expiring images based on age or count.
  # To apply multiple rules, combined them in one policy JSON.
  # https://docs.aws.amazon.com/AmazonECR/latest/userguide/lifecycle_policy_examples.html

  # Production images are tagged with "latest". No other images are tagged
  lifecycle_policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Expire untagged (UAT) images older than 14 days",
            "selection": {
                "tagStatus": "untagged",
                "countType": "sinceImagePushed",
                "countUnit": "days",
                "countNumber": 14
            },
            "action": {
                "type": "expire"
            }
        },
        {
            "rulePriority": 2,
            "description": "Keep the newest 100 production images and mark the rest for expiration",
            "selection": {
                "tagStatus": "tagged",
                "tagPrefixList": ["latest"],
                "countType": "imageCountMoreThan",
                "countNumber": 100
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF


}

resource "kubernetes_secret" "ecr_credentials" {
  metadata {
    name      = "ecr-repo-laa-estimate-financial-eligibility-for-legal-aid"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.ecr_credentials.access_key_id
    secret_access_key = module.ecr_credentials.secret_access_key
    repo_arn          = module.ecr_credentials.repo_arn
    repo_url          = module.ecr_credentials.repo_url
  }
}
