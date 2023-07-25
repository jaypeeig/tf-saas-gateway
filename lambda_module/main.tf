module "lambda" {
  source                = "terraform-aws-modules/lambda/aws"
  version               = "5.3.0"

  function_name         = var.function_name
  description           = var.description
  handler               = var.handler
  runtime               = var.runtime
  source_path           = var.source_path
  memory_size           = var.memory_size
  timeout               = var.timeout
  allowed_triggers      = var.allowed_triggers
  publish               = var.publish
  environment_variables = var.environment_variables
  tags                  = var.tags

  cloudwatch_logs_retention_in_days = var.cloudwatch_logs_retention_in_days
}
