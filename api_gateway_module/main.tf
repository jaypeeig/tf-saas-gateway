module "apigateway-v2" {
  source  = "terraform-aws-modules/apigateway-v2/aws"
  version = "2.2.2"

  name          = var.name
  description   = var.description
  cors_configuration  = var.cors_configuration

}