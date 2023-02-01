provider "aws" {
  region  = "ap-northeast-2"
  profile = "jack"
}

# staging VPC

resource "aws_vpc" "staging" {
  cidr_block           = "10.1.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = { Name = "staging-vpc" }
}

# Public subnet

resource "aws_subnet" "staging_public_subnet_a" {
  vpc_id                  = "${aws_vpc.staging.id}"
  cidr_block              = "10.1.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-2a"
  
  tags = { Name = "staging-public-a" }
}

resource "aws_subnet" "staging_public_subnet_c" {
  vpc_id                  = "${aws_vpc.staging.id}"
  cidr_block              = "10.1.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-2c"
  
  tags = { Name = "staging-public-c" }
}

# Private subnet

resource "aws_subnet" "staging_private_subnet_a" {
  vpc_id                  = "${aws_vpc.staging.id}"
  cidr_block              = "10.1.3.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-2a"
  
  tags = { Name = "staging-private-a" }
}

resource "aws_subnet" "staging_private_subnet_c" {
  vpc_id                  = "${aws_vpc.staging.id}"
  cidr_block              = "10.1.4.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-2c"
  
  tags = { Name = "staging-private-c" }
}

# Public route table

resource "aws_default_route_table" "staging_main" {
  default_route_table_id = "${aws_vpc.staging.default_route_table_id}"

  tags = { Name = "staging Public Route Table" }
}

resource "aws_route_table_association" "staging_public_a" {
	subnet_id      = "${aws_subnet.staging_public_subnet_a.id}"
	route_table_id = "${aws_vpc.staging.default_route_table_id}"
}

resource "aws_route_table_association" "staging_public_c" {
	subnet_id      = "${aws_subnet.staging_public_subnet_c.id}"
	route_table_id = "${aws_vpc.staging.default_route_table_id}"
}

# Private route table

resource "aws_route_table" "staging_private" {
  vpc_id = "${aws_vpc.staging.id}"

  tags = { Name = "staging Route Private Table" }
}

resource "aws_route_table_association" "staging_private_a" {
	subnet_id      = "${aws_subnet.staging_private_subnet_a.id}"
	route_table_id = "${aws_route_table.staging_private.id}"
}

resource "aws_route_table_association" "staging_private_c" {
	subnet_id      = "${aws_subnet.staging_private_subnet_c.id}"
	route_table_id = "${aws_route_table.staging_private.id}"
}
