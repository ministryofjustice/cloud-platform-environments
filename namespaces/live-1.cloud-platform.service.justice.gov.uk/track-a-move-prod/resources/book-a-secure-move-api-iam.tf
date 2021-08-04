# Generate an additional IAM user to manage APIGW
resource "random_id" "book-a-secure-move-api-id" {
  byte_length = 16
}

resource "aws_iam_user" "book-a-secure-move-api-user" {
  name = "book-a-secure-move-api-user-${random_id.book-a-secure-move-api-id.hex}"
  path = "/system/book-a-secure-move-api-user/"
}

resource "aws_iam_access_key" "book-a-secure-move-api-user" {
  user = aws_iam_user.book-a-secure-move-api-user.name
}

data "aws_iam_policy_document" "book-a-secure-move-api" {
  statement {
    actions = [
      "athena:GetQueryExecution",
      "athena:StartQueryExecution",
      "athena:StopQueryExecution",
      "athena:CancelQueryExecution",
      "athena:GetQueryResults",
      "athena:GetWorkGroup",
    ]

    resources = [
      "${aws_athena_workgroup.queries.arn}",
      "${aws_athena_workgroup.queries.arn}/*",
    ]
  }
}

resource "aws_iam_user_policy" "book-a-secure-move-api-policy" {
  name   = "hmpps-book-secure-move-api-production-athena"
  policy = data.aws_iam_policy_document.book-a-secure-move-api.json
  user   = aws_iam_user.book-a-secure-move-api-user.name
}

resource "kubernetes_secret" "track_a_move_book_a_secure_move_api_iam" {
  metadata {
    name      = "book-a-secure-move-api-iam"
    namespace = "hmpps-book-secure-move-api-production"
  }

  data = {
    access_key_id     = aws_iam_access_key.book-a-secure-move-api-user.id
    secret_access_key = aws_iam_access_key.book-a-secure-move-api-user.secret
  }
}
