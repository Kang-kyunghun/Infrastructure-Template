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



# resource "aws_route_table" "staging_public_route_table" {
#   vpc_id = "${aws_vpc.staging.id}"

#   tags = { Name = "staging public route table" }
# }





# #  network acl for public subnets
# resource "aws_network_acl" "staging_public" {
#   vpc_id     = "${aws_vpc.staging.id}"
#   subnet_ids = [
#     "${aws_subnet.staging_public_subnet.id}"
#   ]

#   tags = { Name = "staging public ACL" }
# }

# resource "aws_network_acl_rule" "staging_public_ingress80" {
#   network_acl_id = "${aws_network_acl.staging_public.id}"
#   rule_number = 100
#   rule_action = "allow"
#   egress      = false
#   protocol    = "tcp"
#   cidr_block  = "0.0.0.0/0"
#   from_port   = 80
#   to_port     = 80
# }

# resource "aws_network_acl_rule" "staging_public_egress80" {
#   network_acl_id = "${aws_network_acl.staging_public.id}"
#   rule_number    = 100
#   rule_action    = "allow"
#   egress         = true
#   protocol       = "tcp"
#   cidr_block     = "0.0.0.0/0"
#   from_port      = 80
#   to_port        = 80
# }

# resource "aws_network_acl_rule" "staging_public_ingress443" {
#   network_acl_id = "${aws_network_acl.staging_public.id}"
#   rule_number    = 110
#   rule_action    = "allow"
#   egress         = false
#   protocol       = "tcp"
#   cidr_block     = "0.0.0.0/0"
#   from_port      = 443
#   to_port        = 443
# }

# resource "aws_network_acl_rule" "staging_public_egress443" {
#   network_acl_id = "${aws_network_acl.staging_public.id}"
#   rule_number    = 110
#   rule_action    = "allow"
#   egress         = true
#   protocol       = "tcp"
#   cidr_block     = "0.0.0.0/0"
#   from_port      = 443
#   to_port        = 443
# }

# resource "aws_network_acl_rule" "staging_publicingress22" {
#   network_acl_id = "${aws_network_acl.staging_public.id}"
#   rule_number    = 120
#   rule_action    = "allow"
#   egress         = false
#   protocol       = "tcp"
#   cidr_block     = "0.0.0.0/0"
#   from_port      = 22
#   to_port        = 22
# }

# resource "aws_network_acl_rule" "staging_public_egress22" {
#   network_acl_id = "${aws_network_acl.staging_public.id}"
#   rule_number    = 120
#   rule_action    = "allow"
#   egress         = true
#   protocol       = "tcp"
#   cidr_block     = "${aws_vpc.staging.cidr_block}"
#   from_port      = 22
#   to_port        = 22
# }