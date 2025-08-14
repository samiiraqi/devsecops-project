output "bucket_name"         { value = aws_s3_bucket.app_bucket.bucket }
output "dynamodb_table_name" { value = aws_dynamodb_table.app_table.name }
