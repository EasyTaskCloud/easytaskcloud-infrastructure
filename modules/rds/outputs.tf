output "db_endpoint" {
  value = aws_db_instance.postgres.endpoint
}

output "db_id" {
  value = aws_db_instance.postgres.id
}