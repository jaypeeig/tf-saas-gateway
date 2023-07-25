output "lambda_function_arn" {
  description = "The ARN of the lambda function"
  value       = module.lambda.lambda_function_arn
}

output "lambda_function_invoke_arn" {
  description = "The invoke ARN of the lambda function"
  value       = module.lambda.lambda_function_invoke_arn
}
