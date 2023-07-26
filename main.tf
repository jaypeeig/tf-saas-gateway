terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.9.0"
    }
  }
  required_version = "~> 1.4.4"
}

provider "aws" {
  region  = "ap-southeast-1"
  profile = "sandbox"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
locals {
  region      = data.aws_region.current.name
  account_id  = data.aws_caller_identity.current.account_id
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
  allowed_triggers  = {
    APIGatewayAny = {
      service    = "apigateway"
      source_arn = "arn:aws:execute-api:${local.region}:${local.account_id}:*/authorizers/*"
    },
  } 
  environment_variables = {
    NAME: "AUTHORIZER"
  }

  tags = {
    ENVIRONEMT: "DEV"
  }
}

module "lambda_app" {
  source            = "./lambda_module"
  function_name     = "app-function"
  description       = "test lambda"
  handler           = "index.handler"
  runtime           = "nodejs18.x"
  source_path       = "./src/test-handler"
  memory_size       = 128
  timeout           = 8
  allowed_triggers  = {
    APIGatewayAny = {
      service    = "apigateway"
      source_arn = "arn:aws:execute-api:${local.region}:${local.account_id}:**"
    },
  } 
}
resource "aws_cloudwatch_log_group" "debug-apigateway" {
  name = "debug-apigateway"
  retention_in_days = 1
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

  default_stage_access_log_destination_arn = aws_cloudwatch_log_group.debug-apigateway.arn
  default_stage_access_log_format          = "$context.identity.sourceIp - - [$context.requestTime] \"$context.httpMethod $context.routeKey $context.protocol\" $context.status $context.responseLength $context.requestId $context.integrationErrorMessage -- $context.authorizer.error"
  
  authorizers         = {
    "sapcdc" = {
      authorizer_type                   = "REQUEST"
      identity_sources                  = "$request.header.Authorization"
      name                              = "sapcdc"
      authorizer_payload_format_version = "2.0"
      authorizer_uri                    = module.lambda_authorizer.lambda_function_invoke_arn
    }
  }
  integrations        = {
    "ANY /" = {
      lambda_arn              = module.lambda_app.lambda_function_arn
      payload_format_version  = "2.0"
    }

    "GET /test" = {
      lambda_arn             = module.lambda_app.lambda_function_arn
      payload_format_version = "2.0"
      authorization_type     = "CUSTOM"
      authorizer_key         = "sapcdc"
    }
  }
}

output "apigatewayv2_api_endpoint" {
  value = module.api_gateway_v2.apigatewayv2_api_api_endpoint
}

output "apigatewayv2_api_arn" {
  value = module.api_gateway_v2.apigatewayv2_api_arn
}