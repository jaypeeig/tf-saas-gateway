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
  region = "ap-southeast-1"

  # Make it faster by skipping something
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true

  # skip_requesting_account_id should be disabled to generate valid ARN in apigatewayv2_api_execution_arn
  skip_requesting_account_id = false
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

module "api_gateway" {
  source = "./api_gateway_module"
  name                = "dev-http"
  description         = "My awesome HTTP API Gateway"
  cors_configuration  = {
    allow_headers = ["content-type", "x-amz-date", "authorization", "x-api-key", "x-amz-security-token", "x-amz-user-agent"]
    allow_methods = ["*"]
    allow_origins = ["*"]
  }
  authorizers         = {
    "sap_cdc" = {
      authorizer_type                   = "REQUEST"
      identity_sources                  = "$request.header.Authorization"
      name                              = "sap-cdc-auth"
      authorizer_uri                    = module.lambda_authorizer.lambda_function_arn
      authorizer_payload_format_version = "2.0"
    }
  }
  integrations        = {
    "$default" = {
      lambda_arn = module.lambda_app.lambda_function_arn
      authorizer_key   = "sap_cdc"
    }
  }
}

