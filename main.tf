terraform {
  backend "s3" {
    bucket         = "482745811129-terraform-tfstate" # Твій ID
    key            = "dev/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "terraform-tfstate-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = "eu-central-1"
}

# Виклик твого модуля таблиць
module "dynamodb_tables" {
  source  = "./modules/dynamodb"
  context = module.label.context
}

# Налаштування префіксів для імен
module "label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  namespace = "univ"
  stage     = "dev"
  name      = "lab"
} 
# Додай це під блоком module "dynamodb_tables"
module "iam" {
  source  = "./modules/iam"
  context = module.label.context
}

module "lambda_functions" {
  source       = "./modules/lambda"
  context      = module.label.context
  iam_role_arn = module.iam.lambda_role_arn
}