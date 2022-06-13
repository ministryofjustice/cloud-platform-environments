module "es_bucket" {

  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=4.7.1"
  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }

}

resource "kubernetes_secret" "es_bucket" {
  metadata {
    name      = "es-bucket"
    namespace = var.namespace
  }

  data = {
    bucket_arn        = module.es_bucket.bucket_arn
    bucket_name       = module.es_bucket.bucket_name
    access_key_id     = module.es_bucket.access_key_id
    secret_access_key = module.es_bucket.secret_access_key
  }
}

resource "aws_iam_role" "es_bucket" {
  name = "raz-es-migrate-role"
  path = "/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "es.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "es_bucket" {
  name = "raz-es-migrate-role-policy"
  role = aws_iam_role.es_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:*"
        ],
        Resource = module.es_bucket.bucket_arn
      },
      {
        Effect = "Allow",
        Action = [
          "s3:*"
        ],
        Resource = "${module.es_bucket.bucket_arn}/*"
      }
    ]
  })
}
