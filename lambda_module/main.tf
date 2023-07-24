module "lambda" {
  source  = "terraform-aws-modules/lambda/aws"

  function_name         = var.function_name
  description           = var.description
  handler               = var.handler
  runtime               = var.runtime
  source_path           = var.source_path
  memory_size           = var.memory_size
  timeout               = var.timeout
  environment_variables = var.environment_variables
  tags                  = var.tags
}
