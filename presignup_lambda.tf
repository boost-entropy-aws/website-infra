
module "presignup_cognito" {
  source        = "./lambdas"
  function_name = "PresignupCognito"
  source_bucket = var.lambda_source_bucket
  source_key    = var.cognito_preauth_handler_source_key
  environment_variables =  {
    table_name   = var.dynamodb_table_name
  }

  additional_policy    = false
  handler              = var.cognito_preauth_handler_name
  function_url_enabled = false
  app_name             = var.app_name

  runtime = "nodejs14.x"
}


resource "aws_lambda_permission" "cognito" {
  statement_id  = "AllowExecutionFromCognito"
  action        = "lambda:InvokeFunction"
  function_name = module.presignup_cognito.function_name
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = module.cognito_user_pool.arn
}
