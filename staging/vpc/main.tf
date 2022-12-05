provider "aws" {
  region  = "ap-northeast-2"
  profile = "jack"
}

# Staging VPC

resource "aws_vpc" "staging" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = { Name = "staging" }
}

resource "aws_route_table" "staging_public_route_table" {
  vpc_id = "${aws_vpc.staging.id}"

  tags = { Name = "staging public route table" }
}


# Public subnet

resource "aws_subnet" "staging_public_subnet" {
  vpc_id                  = "${aws_vpc.staging.id}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-2a"
  
  tags = { Name = "staging public AZ-a" }
}

# Internet gatway

resource "aws_internet_gateway" "staging_igw" {
  vpc_id = "${aws_vpc.staging.id}"
  
  tags = { Name = "internet-gateway" }
}

resource "aws_route" "staging_internet_access" {
  route_table_id         = "${aws_route_table.staging_public_route_table.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.staging_igw.id}"
}

#  network acl for public subnets
resource "aws_network_acl" "staging_public" {
  vpc_id     = "${aws_vpc.staging.id}"
  subnet_ids = [
    "${aws_subnet.staging_public_subnet.id}"
  ]

  tags = { Name = "staging public ACL" }
}

resource "aws_network_acl_rule" "staging_public_ingress80" {
  network_acl_id = "${aws_network_acl.staging_public.id}"
  rule_number = 100
  rule_action = "allow"
  egress      = false
  protocol    = "tcp"
  cidr_block  = "0.0.0.0/0"
  from_port   = 80
  to_port     = 80
}

resource "aws_network_acl_rule" "staging_public_egress80" {
  network_acl_id = "${aws_network_acl.staging_public.id}"
  rule_number    = 100
  rule_action    = "allow"
  egress         = true
  protocol       = "tcp"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "staging_public_ingress443" {
  network_acl_id = "${aws_network_acl.staging_public.id}"
  rule_number    = 110
  rule_action    = "allow"
  egress         = false
  protocol       = "tcp"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "staging_public_egress443" {
  network_acl_id = "${aws_network_acl.staging_public.id}"
  rule_number    = 110
  rule_action    = "allow"
  egress         = true
  protocol       = "tcp"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "staging_publicingress22" {
  network_acl_id = "${aws_network_acl.staging_public.id}"
  rule_number    = 120
  rule_action    = "allow"
  egress         = false
  protocol       = "tcp"
  cidr_block     = "0.0.0.0/0"
  from_port      = 22
  to_port        = 22
}

resource "aws_network_acl_rule" "staging_public_egress22" {
  network_acl_id = "${aws_network_acl.staging_public.id}"
  rule_number    = 120
  rule_action    = "allow"
  egress         = true
  protocol       = "tcp"
  cidr_block     = "${aws_vpc.staging.cidr_block}"
  from_port      = 22
  to_port        = 22
}