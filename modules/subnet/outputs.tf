output "public_subnet_ids" {
  value = [for s in aws_subnet.public : s.id]
}


output "private_subnet_ids" {
  value = [for s in aws_subnet.privet : s.id]
}
