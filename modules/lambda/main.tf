variable "iam_role_arn" { type = string }

# Описуємо архівацію коду (Terraform сам зробить .zip)
data "archive_file" "lambda_zip" {
  for_each    = toset(["get-all-authors", "get-all-courses", "get-course", "save-course", "update-course", "delete-course"])
  type        = "zip"
  source_dir  = "${path.root}/lambdas/${each.key}"
  output_path = "${path.root}/lambdas/${each.key}.zip"
}

# Створюємо самі функції в AWS
resource "aws_lambda_function" "api_lambdas" {
  for_each      = data.archive_file.lambda_zip
  filename      = each.value.output_path
  function_name = each.key
  role          = var.iam_role_arn
  handler       = "index.handler"
  runtime       = "nodejs18.x" # Актуальна версія Node.js [cite: 80]

  source_code_hash = each.value.output_base64sha256
}