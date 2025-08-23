output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnet_ids" {
  value = [for az, _ in local.az_map : aws_subnet.public[az].id]
}

output "private_subnet_ids" {
  value = [for az, _ in local.az_map : aws_subnet.private[az].id]
}
