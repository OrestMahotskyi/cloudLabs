# --- 1. Основний API Gateway ---
resource "aws_api_gateway_rest_api" "api" {
  name        = "univ-dev-lab-api"
  description = "API для керування курсами та авторами"
}

# --- 2. Ресурс /authors (Отримання списку авторів) ---
resource "aws_api_gateway_resource" "authors" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "authors"
}

resource "aws_api_gateway_method" "get_authors" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.authors.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_authors_int" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.authors.id
  http_method             = aws_api_gateway_method.get_authors.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.lambda_functions.api_lambdas["get-all-authors"].invoke_arn
}

# --- 3. Ресурс /courses (Колекція курсів) ---
resource "aws_api_gateway_resource" "courses" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "courses"
}

# GET /courses (Отримати всі)
resource "aws_api_gateway_method" "get_all_courses" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.courses.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_all_courses_int" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.courses.id
  http_method             = aws_api_gateway_method.get_all_courses.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.lambda_functions.api_lambdas["get-all-courses"].invoke_arn
}

# POST /courses (Створити новий)
resource "aws_api_gateway_method" "save_course" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.courses.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "save_course_int" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.courses.id
  http_method             = aws_api_gateway_method.save_course.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.lambda_functions.api_lambdas["save-course"].invoke_arn
}

# --- 4. Ресурс /courses/{id} (Окремий курс для UPDATE та DELETE) ---
resource "aws_api_gateway_resource" "course_item" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.courses.id
  path_part   = "{id}"
}

# PUT /courses/{id} (Оновити)
resource "aws_api_gateway_method" "update_course" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.course_item.id
  http_method   = "PUT"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "update_course_int" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.course_item.id
  http_method             = aws_api_gateway_method.update_course.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.lambda_functions.api_lambdas["update-course"].invoke_arn
}

# DELETE /courses/{id} (Видалити)
resource "aws_api_gateway_method" "delete_course" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.course_item.id
  http_method   = "DELETE"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "delete_course_int" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.course_item.id
  http_method             = aws_api_gateway_method.delete_course.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.lambda_functions.api_lambdas["delete-course"].invoke_arn
}

# --- 5. Налаштування CORS (Метод OPTIONS для браузера) ---
# Це спрощений варіант CORS для всіх ресурсів
module "cors_courses" {
  source  = "squidfunk/api-gateway-enable-cors/aws"
  version = "0.3.3"
  api_id          = aws_api_gateway_rest_api.api.id
  api_resource_id = aws_api_gateway_resource.courses.id
}

module "cors_authors" {
  source  = "squidfunk/api-gateway-enable-cors/aws"
  version = "0.3.3"
  api_id          = aws_api_gateway_rest_api.api.id
  api_resource_id = aws_api_gateway_resource.authors.id
}

module "cors_course_item" {
  source  = "squidfunk/api-gateway-enable-cors/aws"
  version = "0.3.3"
  api_id          = aws_api_gateway_rest_api.api.id
  api_resource_id = aws_api_gateway_resource.course_item.id
}

# --- 6. Дозволи для Lambda ---
resource "aws_lambda_permission" "apigw_lambda" {
  for_each      = module.lambda_functions.api_lambdas
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = each.value.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

# --- 7. Деплой API ---
resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on = [
    aws_api_gateway_integration.get_all_courses_int,
    aws_api_gateway_integration.save_course_int,
    aws_api_gateway_integration.update_course_int,
    aws_api_gateway_integration.delete_course_int,
    aws_api_gateway_integration.get_authors_int
  ]
  rest_api_id = aws_api_gateway_rest_api.api.id
}

resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = "prod"
}

# --- 8. Вихідні дані ---
output "api_url" {
  value = aws_api_gateway_stage.prod.invoke_url
}