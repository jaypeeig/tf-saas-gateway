output "apigatewayv2_api_id" {
  description = "The API identifier"
  value       = try(module.apigateway_v2.id, "")
}

output "apigatewayv2_api_api_endpoint" {
  description = "The URI of the API"
  value       = try(module.apigateway_v2.api_endpoint, "")
}

output "apigatewayv2_api_arn" {
  description = "The ARN of the API"
  value       = try(module.apigateway_v2.arn, "")
}