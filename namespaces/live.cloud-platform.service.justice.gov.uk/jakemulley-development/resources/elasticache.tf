module "redis_7" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-elasticache-cluster?ref=6.1.0"

  # VPC configuration
  vpc_name = var.vpc_name

  # Redis configuration
  engine_version       = "7.0"
  parameter_group_name = "default.redis7"
  node_type            = "cache.t4g.micro"

  # Tags
  team_name              = var.team_name
  namespace              = var.namespace
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
}

resource "kubernetes_secret" "redis_7" {
  metadata {
    name      = "${var.team_name}-ec-cluster-output"
    namespace = var.namespace
  }

  data = {
    primary_endpoint_address = module.redis_7.primary_endpoint_address
    member_clusters          = jsonencode(module.redis_7.member_clusters)
    auth_token               = module.redis_7.auth_token
    access_key_id            = module.redis_7.access_key_id
    secret_access_key        = module.redis_7.secret_access_key
    replication_group_id     = module.redis_7.replication_group_id
  }
}

# sigv4/iam auth proof of concept - this is broad policy on purpose
resource "aws_elasticache_user_group" "test" {
  engine        = "REDIS"
  user_group_id = "${var.namespace}-ug"
  user_ids      = [aws_elasticache_user.ec_iam_auth.user_id]
}

resource "aws_elasticache_user" "ec_iam_auth" {
  access_string = "on ~* +@all"
  engine        = "REDIS"
  user_id       = "default"
  user_name     = "default"

  authentication_mode {
    type = "iam"
  }
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "ec_iam_auth_assume" {
  version = "2012-10-17"
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
}

resource "aws_iam_role" "ec_iam_auth" {
  name               = "${var.namespace}-ec-iam-auth"
  assume_role_policy = data.aws_iam_policy_document.ec_iam_auth_assume.json
}

data "aws_iam_policy_document" "ec_iam_auth" {
  version = "2012-10-17"
  statement {
    effect  = "Allow"
    actions = ["elasticache:Connect"]
    resources = [
      "arn:aws:elasticache:eu-west-2:${data.aws_caller_identity.current.account_id}:replicationgroup:${module.redis_7.replication_group_id}",
      aws_elasticache_user.ec_iam_auth.arn
    ]
  }
}

resource "aws_iam_policy" "ec_iam_auth" {
  name   = "${var.namespace}-ec_iam_auth"
  policy = data.aws_iam_policy_document.ec_iam_auth.json
}

resource "aws_iam_role_policy_attachment" "ec_iam_auth" {
  role       = aws_iam_role.ec_iam_auth.name
  policy_arn = aws_iam_policy.ec_iam_auth.arn
}

# I will manually add the IAM user to the Redis cluster
