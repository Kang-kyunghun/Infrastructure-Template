provider "aws" {
  region  = "ap-northeast-2"
  profile = "jack"
}

data "terraform_remote_state" "DMZ_vpc" {
  backend = "local"

  config = {
    path = "../../../vpc/terraform.tfstate"
  }
}

resource "aws_security_group" "public_api" {
  vpc_id      = data.terraform_remote_state.DMZ_vpc.outputs.DMZ_vpc_id
  name        = "Public API EC2 Security Group"
  description = "Public API EC2 Security Group"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 8000
    to_port   = 8000
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Public API EC2 Security Group"
  }
}

resource "aws_instance" "public_api" {
  ami                    = "ami-0d19691dd2d866cb6"
  instance_type          = "t2.micro"
  key_name               = "terraform-tamplate-public-api"
  vpc_security_group_ids = [aws_security_group.public_api.id]
  subnet_id              = data.terraform_remote_state.DMZ_vpc.outputs.DMZ_public_subnet_a_id

  tags = {
    Name = "public-api"
  }
}


resource "aws_security_group" "db" {
  vpc_id      = data.terraform_remote_state.DMZ_vpc.outputs.DMZ_vpc_id
  name        = "DMZ DB Security Group"
  description = "DMZ DB Security Group"

  ingress {
    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "DMZ DB"
  }
}


resource "aws_db_subnet_group" "db" {
  name        = "public-db"
  description = "public-db RDS Subnet Group"
  subnet_ids  = [data.terraform_remote_state.DMZ_vpc.outputs.DMZ_public_subnet_a_id, data.terraform_remote_state.DMZ_vpc.outputs.DMZ_public_subnet_c_id]
}

resource "aws_db_parameter_group" "db" {
  name   = "public-db"
  family = "mysql5.7"

  ## Change char settings so that korean texts can be written/read properly
  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_connection"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_database"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_results"
    value = "utf8mb4"
  }

  parameter {
    name  = "collation_connection"
    value = "utf8mb4_general_ci"
  }

  parameter {
    name  = "collation_server"
    value = "utf8mb4_unicode_ci"
  }
}

resource "aws_db_instance" "db" {
  allocated_storage                   = 8
  engine                              = "mysql"
  engine_version                      = "5.7.38"
  instance_class                      = "db.t2.micro"
  identifier                          = "public-db"
  username                            = "root"
  password                            = "kucie271150"
  iam_database_authentication_enabled = true
  vpc_security_group_ids              = [aws_security_group.db.id]

  db_subnet_group_name = aws_db_subnet_group.db.id
  parameter_group_name = aws_db_parameter_group.db.id

  multi_az            = false
  storage_type        = "gp2"
  publicly_accessible = true #나중에 false
  storage_encrypted   = false

  allow_major_version_upgrade = false
  auto_minor_version_upgrade  = false
  apply_immediately           = true
  maintenance_window          = "Mon:00:00-Mon:03:00"
  skip_final_snapshot         = true
  copy_tags_to_snapshot       = false
  backup_retention_period     = 1
  backup_window               = "09:00-10:00"

  tags = { Name = "public-db" }
}