terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.61.0"
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
  source_path   = "./src/lambda-handler"
  memory_size   = 256
  timeout       = 20
  environment_variables = {
    NAME: "AUTHORIZER"
  }

  tags = {
    ENVIRONEMT: "DEV"
  }

}