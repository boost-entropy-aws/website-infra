resource "aws_lambda_function" "lambda" {
  function_name = "${var.app_name}${var.function_name}"

  s3_bucket   = var.source_bucket
  s3_key      = var.source_key
  memory_size = 512
  timeout     = 60
  environment {
    variables = var.environment_variables
  }

  runtime = var.runtime
  handler = var.handler

  role = aws_iam_role.lambda_exec.arn
}
resource "aws_lambda_function_url" "lambda_url" {
  count              = var.function_url_enabled ? 1 : 0
  function_name      = aws_lambda_function.lambda.function_name
  authorization_type = "NONE"
  cors {
    allow_credentials = true
    allow_origins     = ["*"]
    allow_methods     = ["*"]
    allow_headers     = ["*"]
    expose_headers    = ["*"]
    max_age           = 86400
  }
}

resource "aws_cloudwatch_log_group" "lambda" {
  name = "/aws/lambda/${aws_lambda_function.lambda.function_name}"

  retention_in_days = 30
}

resource "aws_iam_role" "lambda_exec" {
  name = "${var.app_name}_${var.function_name}_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
resource "aws_iam_policy" "lambda_policy" {
count = var.additional_policy?1:0 
  name   = "${var.function_name}_policy"
  policy = var.policy
}
resource "aws_iam_role_policy_attachment" "lambda_policy" {
  count = var.additional_policy ?1:0 
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_policy[0].arn
}

