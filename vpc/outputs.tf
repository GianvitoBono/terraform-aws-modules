output "vpc_id" {
  value = aws_vpc.main.id
}

output "private_subnets" {
  value = [for sub in aws_subnet.private_subnet : sub.id]
}

output "public_subnets" {
  value = [for sub in aws_subnet.public_subnet : sub.id]
}