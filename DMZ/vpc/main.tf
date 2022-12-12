provider "aws" {
  region  = "ap-northeast-2"
  profile = "jack"
}

# DMZ VPC

resource "aws_vpc" "DMZ" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = { Name = "DMZ-vpc" }
}

# # Public subnet

resource "aws_subnet" "DMZ_public_subnet_a" {
  vpc_id                  = "${aws_vpc.DMZ.id}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-2a"
  
  tags = { Name = "DMZ-public-a" }
}

resource "aws_subnet" "DMZ_public_subnet_c" {
  vpc_id                  = "${aws_vpc.DMZ.id}"
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-2c"
  
  tags = { Name = "DMZ-public-c" }
}

resource "aws_default_route_table" "DMZ_main" {
  default_route_table_id = "${aws_vpc.DMZ.default_route_table_id}"

  tags = { Name = "DMZ Public Route Table" }
}

resource "aws_route_table_association" "DMZ_public_a" {
	subnet_id      = "${aws_subnet.DMZ_public_subnet_a.id}"
	route_table_id = "${aws_vpc.DMZ.default_route_table_id}"
}

resource "aws_route_table_association" "DMZ_public_c" {
	subnet_id      = "${aws_subnet.DMZ_public_subnet_c.id}"
	route_table_id = "${aws_vpc.DMZ.default_route_table_id}"
}

# Internet gatway

resource "aws_internet_gateway" "DMZ_igw" {
  vpc_id = "${aws_vpc.DMZ.id}"
  
  tags = { Name = "DMZ internet-gateway" }
}

resource "aws_route" "DMZ_public" {
  route_table_id         = "${aws_vpc.DMZ.default_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.DMZ_igw.id}"
}