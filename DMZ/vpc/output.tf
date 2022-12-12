output "DMZ_vpc_id" {
  value = aws_vpc.DMZ.id
}

output "DMZ_public_subnet_a_id" {
  value = aws_subnet.DMZ_public_subnet_a.id
}

output "DMZ_public_subnet_c_id" {
  value = aws_subnet.DMZ_public_subnet_c.id
}