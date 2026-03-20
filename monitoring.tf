# --- 0. PROVIDERS ---
# Додатковий провайдер для Billing (метрики грошей працюють тільки в Вірджинії)
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

# --- 1. SNS TOPIC & SUBSCRIPTION ---
resource "aws_sns_topic" "alerts" {
  name = "univ-lab-alerts"
}

resource "aws_sns_topic_subscription" "email_sub" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = "orest.mahotskyi.ri.2024@lpnu.ua"
}

# --- 2. BILLING ALARM (Моніторинг витрат) ---
resource "aws_cloudwatch_metric_alarm" "billing_alarm" {
  provider            = aws.us_east_1
  alarm_name          = "billing-alarm-over-1-dollar"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "EstimatedCharges"
  namespace           = "AWS/Billing"
  period              = "21600" # 6 годин
  statistic           = "Maximum"
  threshold           = "1.0"
  alarm_description   = "Сповіщення про перевищення витрат $1"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    Currency = "USD"
  }
}

# --- 3. LAMBDA ERROR ALARM (Помилки в коді) ---
resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "lambda-errors-alert"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "60" # 1 хвилина
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "Моніторинг помилок у всіх лямбда-функціях"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  treat_missing_data  = "notBreaching"
}

# --- 4. API GATEWAY 5XX ALARM (Доступність API) ---
resource "aws_cloudwatch_metric_alarm" "api_5xx_errors" {
  alarm_name          = "api-gateway-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "5XXError"
  namespace           = "AWS/ApiGateway"
  period              = "60"
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "Серверні помилки на API Gateway"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    ApiName = aws_api_gateway_rest_api.api.name
  }
}
