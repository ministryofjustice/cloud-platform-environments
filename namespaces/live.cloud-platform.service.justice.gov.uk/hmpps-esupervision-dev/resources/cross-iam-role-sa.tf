data "aws_iam_policy_document" "assume_rekognition_role" {
  statement {
    sid = "AssumeRekognitionRole"
    actions = ["sts:AssumeRole"]
    effect = "Allow"
    resources = [var.rekognition_role_arn]
  }
}

resource "aws_iam_policy" "assume_rekognition_policy" {
  name = "${var.namespace}-allow-assume-rekognition"
  policy = data.aws_iam_policy_document.assume_rekognition_role.json

  tags = {
    business-unit = var.business_unit
    application = var.application
    is-production = var.is_production
    environment-name = var.environment
    owner = var.team_name
    infrastructure-support = var.infrastructure_support
  }  
}