output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.astrolog_function.function_name
}

output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.astrolog_function.arn
}

output "lambda_layer_arn" {
  description = "ARN of the Astrolog Lambda layer"
  value       = aws_lambda_layer_version.astrolog_layer.arn
}

output "lambda_function_url" {
  description = "Lambda Function URL (if enabled)"
  value       = var.enable_function_url ? aws_lambda_function_url.astrolog_function_url[0].function_url : null
}

output "lambda_role_arn" {
  description = "ARN of the IAM role for Lambda function"
  value       = aws_iam_role.lambda_role.arn
}
