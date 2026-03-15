module "label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  context = var.context
}

resource "aws_dynamodb_table" "courses" {
  name         = "${module.label.id}-courses"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = module.label.tags
}

resource "aws_dynamodb_table" "authors" {
  name         = "${module.label.id}-authors"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = module.label.tags
}