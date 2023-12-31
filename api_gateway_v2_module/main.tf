module "apigateway_v2" {
  source                  = "terraform-aws-modules/apigateway-v2/aws"
  version                 = "2.2.2"

  name                    = var.name
  description             = var.description
  cors_configuration      = var.cors_configuration
  authorizers             = var.authorizers
  integrations            = var.integrations
  create_api_domain_name  = var.create_api_domain_name

  default_stage_access_log_destination_arn = var.default_stage_access_log_destination_arn
  default_stage_access_log_format          = var.default_stage_access_log_format
}