output "apigatewayv2_api_id" {
  description = "The API identifier"
  value       = try(aws_apigatewayv2_api.this[0].id, "")
}

output "apigatewayv2_api_api_endpoint" {
  description = "The URI of the API"
  value       = try(aws_apigatewayv2_api.this[0].api_endpoint, "")
}

output "apigatewayv2_api_arn" {
  description = "The ARN of the API"
  value       = try(aws_apigatewayv2_api.this[0].arn, "")
}