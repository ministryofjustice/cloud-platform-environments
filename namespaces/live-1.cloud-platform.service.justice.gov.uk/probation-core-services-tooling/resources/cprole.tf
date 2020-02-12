resource "aws_iam_role" "pcst-role" {
  name               = "cloud-platform-probation-core-services-tooling-role"
  description        = "A service-specific role which can be assumed by a suitably configured pod/namespace"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    },
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::754256621582:role/kiam-server"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}

resource "aws_iam_policy" "pcst-policy" {
  name        = "cloud-platform-probation-core-services-tooling-policy"
  description = "Allows the role to assume any role in the hmpps-sandpit account"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Resource": "arn:aws:iam::434401102446:role/*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "service" {
  role       = aws_iam_role.pcst-role.name
  policy_arn = aws_iam_policy.pcst-policy.arn
}

