module "mod_bedrock_irsa" {
  source           = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"
  namespace        = var.namespace
  eks_cluster_name = var.eks_cluster_name
  role_policy_arns = {
    bedrock = aws_iam_policy.access_bedrock_service.arn
  }
  service_account_name = "${var.namespace}-to-mod-platform-bedrock-sa"

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "aws_iam_policy" "access_bedrock_service" {
  name   = "AccessBedrockService"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Resource = "arn:aws:iam::321388111150:role/BedrockAccessforCP"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_bedrock_policy" {
  role       = module.mod_bedrock_irsa.role_name
  policy_arn = aws_iam_policy.access_bedrock_service.arn
}

resource "kubernetes_secret" "irsa" {
  metadata {
    name      = "irsa-output"
    namespace = var.namespace
  }
  data = {
    role           = module.mod_bedrock_irsa.role_name
    serviceaccount = module.mod_bedrock_irsa.service_account.name
    rolearn        = module.mod_bedrock_irsa.role_arn
  }
}
