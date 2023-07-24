module "lambda" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 2.0"

  function_name = var.function_name
  handler       = var.handler
  runtime       = var.runtime
  // Rest of the variables as per your need
}
