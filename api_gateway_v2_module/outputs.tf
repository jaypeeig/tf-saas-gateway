output "apigatewayv2_api_id" {
  description = "The API identifier"
  value       = module.apigateway_v2.apigatewayv2_api_id
}

output "apigatewayv2_api_api_endpoint" {
  description = "The URI of the API"
  value       = module.apigateway_v2.apigatewayv2_api_api_endpoint
}

output "apigatewayv2_api_arn" {
  description = "The ARN of the API"
  value       = module.apigateway_v2.apigatewayv2_api_arn
}