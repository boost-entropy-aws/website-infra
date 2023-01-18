
output "function_arn" {
  value = aws_lambda_function.lambda.arn
}
output "function_url" {
  value = var.function_url_enabled ? "${aws_lambda_function_url.lambda_url[0].function_url}" : ""

}
output "function_name" {
  value = aws_lambda_function.lambda.function_name
  
}
output "lambda_role_arn" {
  value = aws_iam_role.lambda_exec.arn


}
