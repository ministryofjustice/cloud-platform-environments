resource "aws_iam_role" "codebuild_role" {
  name = "${var.project_name}-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "codebuild_policy" {
  name        = "${var.project_name}-policy"
  path        = "/service-role/"
  description = "Policy used in trust relationship with CodeBuild"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    }
  ]
}
POLICY
}

resource "aws_iam_policy_attachment" "codebuild_policy_attachment" {
  name       = "${var.project_name}-policy-attachment"
  policy_arn = "${aws_iam_policy.codebuild_policy.arn}"
  roles      = ["${aws_iam_role.codebuild_role.id}"]
}

resource "aws_codebuild_project" "codebuild_project" {
  name         = "${var.project_name}"
  description  = "codebuild project"
  build_timeout      = "5"
  service_role = "${aws_iam_role.codebuild_role.arn}"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/ubuntu-base:14.04"
    type         = "LINUX_CONTAINER"
  }

  source {
    type     = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }
}
