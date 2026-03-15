output "courses_table_arn" {
  value       = module.dynamodb_tables.courses_table_arn
}

output "authors_table_arn" {
  value       = module.dynamodb_tables.authors_table_arn
}