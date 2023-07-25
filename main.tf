terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = "~> 1.4.4"
}


provider "aws" {
  region  = "ap-southeast-1"
  profile = "sandbox"
}

module "lambda_authorizer" {
  source        = "./lambda_module"
  function_name = "auth-function"
  description   = "custom lambda authorizer"
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  source_path   = "./src/auth-handler"
  memory_size   = 128
  timeout       = 20
  environment_variables = {
    NAME: "AUTHORIZER"
  }

  tags = {
    ENVIRONEMT: "DEV"
  }
}

module "lambda_app" {
  source        = "./lambda_module"
  function_name = "app-function"
  description   = "test lambda"
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  source_path   = "./src/test-handler"
  memory_size   = 128
  timeout       = 8
}

module "api_gateway_v2" {
  source = "./api_gateway_v2_module"
  name                = "dev-http"
  description         = "My awesome HTTP API Gateway"
  cors_configuration  = {
    allow_headers = ["content-type", "x-amz-date", "authorization", "x-api-key", "x-amz-security-token", "x-amz-user-agent"]
    allow_methods = ["*"]
    allow_origins = ["*"]
  }
  authorizers         = {
    "sap_cdc" = {
      authorizer_type                   = "TOKEN"
      identity_sources                  = "$request.header.Authorization"
      name                              = "sap_cdc"
      authorizer_payload_format_version = "1.0"
    }
  }
  integrations        = {

    "ANY /" = {
      lambda_arn              = module.lambda_app.lambda_function_arn
      payload_format_version  = "1.0"
    }

    "$default" = {
      lambda_arn = module.lambda_app.lambda_function_arn
    }
}

output "apigatewayv2_api_api_endpoint" {
  value = module.api_gateway_v2.apigatewayv2_api_api_endpoint
}