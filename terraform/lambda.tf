resource "aws_lambda_function" "image_tag_lambda" {
  function_name = "image_tag_lambda"
  role          = aws_iam_role.lambda_exec_role.arn
  runtime       = "python3.13"
  handler       = "app.lambda_handler"

  filename         = "${path.module}/../backend/image_lambda.zip"
  source_code_hash = filebase64sha256("${path.module}/../backend/image_lambda.zip")

  environment {
    variables = {
      BUCKET = var.bucket_name
    }
  }

  timeout = 900
  memory_size  = 512
}

resource "aws_s3_bucket_notification" "lambda_trigger" {
  bucket = var.bucket_name

  lambda_function {
    lambda_function_arn = aws_lambda_function.image_tag_lambda.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_s3]
}

resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.image_tag_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${var.bucket_name}"
}

resource "aws_iam_policy" "lambda_dynamodb_policy" {
  name = "LambdaDynamoDBPolicy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "dynamodb:PutItem"
        ],
        Effect   = "Allow",
        Resource = aws_dynamodb_table.image_labels.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_dynamodb_attach" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_dynamodb_policy.arn
}