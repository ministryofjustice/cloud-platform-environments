data "aws_caller_identity" "current" {}

data "aws_eks_cluster" "eks_cluster" {
  name = var.eks_cluster_name
}

data "aws_secretsmanager_secret" "circleci" {
  name = "cloud-platform-circleci"
}

data "aws_secretsmanager_secret_version" "circleci" {
  secret_id = data.aws_secretsmanager_secret.circleci.id
}

resource "aws_iam_role" "bankwizard_bucket_assumable_role" {
  name               = "bankwizard-bucket-assumable-role-oidc-prod" # This is the name of the role 
  assume_role_policy = data.aws_iam_policy_document.circleci_assume_role_policy.json
}

#policy to allow circle to assume role
data "aws_iam_policy_document" "circleci_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "oidc.circleci.com/org/${jsondecode(data.aws_secretsmanager_secret_version.circleci.secret_string)["organisation_id"]}:aud"
      values   = [jsondecode(data.aws_secretsmanager_secret_version.circleci.secret_string)["organisation_id"]]
    }

    condition {
      test     = "StringLike"
      variable = "oidc.circleci.com/org/${jsondecode(data.aws_secretsmanager_secret_version.circleci.secret_string)["organisation_id"]}:sub"
      values   = ["org/${jsondecode(data.aws_secretsmanager_secret_version.circleci.secret_string)["organisation_id"]}/project/${var.experian_project_id}/user/*"]
    }

    principals {
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/oidc.circleci.com/org/${jsondecode(data.aws_secretsmanager_secret_version.circleci.secret_string)["organisation_id"]}"]
      type        = "Federated"
    }
  }
}


data "aws_iam_policy_document" "allow_circle_role_s3" {
  statement {
    actions   = ["s3:GetObjectVersion", "s3:GetObject", "s3:PutObject"]
    effect    = "Allow"
    resources = ["${module.bankwizard_artifact_bucket.bucket_arn}/*"]

  }
  statement {
    actions   = ["s3:ListBucket"]
    effect    = "Allow"
    resources = ["${module.bankwizard_artifact_bucket.bucket_arn}/"]

  }
}

resource "aws_iam_policy" "allow_circle_role_s3" {
  name        = "allow-circle-s3-prod"
  description = "Policy allowing Circle assumable role access to S3."
  policy      = data.aws_iam_policy_document.allow_circle_role_s3.json
}

#Attach policy to assumable role.
resource "aws_iam_role_policy_attachment" "allow_circle_s3_attach" {
  role       = aws_iam_role.bankwizard_bucket_assumable_role.name
  policy_arn = aws_iam_policy.allow_circle_role_s3.arn
}

resource "kubernetes_secret" "bankwizard_artifact_bucket_role" {
  metadata {
    name      = "bankwizard-artifact-bucket-role-output"
    namespace = var.namespace
  }

  data = {
    bucket_role_arn = aws_iam_role.bankwizard_bucket_assumable_role.arn
  }
}
