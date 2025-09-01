terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "tc-terraform-state-storage-s3"
    key            = "app-dev-networking-2"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locking"
    encrypt        = true
  }
}


provider "aws" {
  region = "us-east-1"
}

# VPC
resource "aws_vpc" "DEV-VPC" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "DEV-VPC"
  }
}

# PUBLIC SUBNETS
resource "aws_subnet" "public_subnet" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.DEV-VPC.id
  cidr_block              = element(var.public_subnet_cidrs, count.index)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "DEV VPC"
  }
}

# LAMBDA SUBNETS
resource "aws_subnet" "lambda_subnet" {
  count             = length(var.lambda_subnet_cidrs)
  vpc_id            = aws_vpc.DEV-VPC.id
  cidr_block        = element(var.lambda_subnet_cidrs, count.index)
  availability_zone = element(var.azs, count.index)
  tags = {
    Name = "Lambda Subnet ${count.index + 1}"
  }
}

# DATABASE SUBNETS
resource "aws_subnet" "test_db_01_subnet" {
  count             = length(var.database_subnet_cidrs)
  vpc_id            = aws_vpc.DEV-VPC.id
  cidr_block        = element(var.database_subnet_cidrs, count.index)
  availability_zone = element(var.azs, count.index)

  tags = {
    Name = "Database Subnet ${count.index + 1}"
  }
}

# INTERNET GATEWAY
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.DEV-VPC.id

  tags = {
    Name = "DEV VPC Internet Gateway"
  }
}

# ELASTIC IP ADDRESS
resource "aws_eip" "nat_eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.igw]
}

# NAT Gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = element(aws_subnet.public_subnet.*.id, 0)
  depends_on    = [aws_internet_gateway.igw]
  tags = {
    Name = "DEV VPC NAT Gateway"
  }

}


# ROUTE TABLES -----------------------------------------
resource "aws_route_table" "public_table" {
  vpc_id = aws_vpc.DEV-VPC.id
}

resource "aws_route_table" "private_table" {
  vpc_id = aws_vpc.DEV-VPC.id
}

# ROUTES ------------------------------------------------
resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route" "private_route" {
  route_table_id         = aws_route_table.private_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

# Route Table Associations
# RTA --------------------------------------------------
resource "aws_route_table_association" "public_assoc" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
  route_table_id = aws_route_table.public_table.id
}

resource "aws_route_table_association" "lambda_assoc" {
  count          = length(var.lambda_subnet_cidrs)
  subnet_id      = element(aws_subnet.lambda_subnet.*.id, count.index)
  route_table_id = aws_route_table.public_table.id
}

resource "aws_route_table_association" "database_assoc" {
  count          = length(var.database_subnet_cidrs)
  subnet_id      = element(aws_subnet.test_db_01_subnet.*.id, count.index)
  route_table_id = aws_route_table.private_table.id
}

# Security Groups
# SGS ------------------------------------------------
resource "aws_security_group" "lambda_sg" {
  name        = "dev_vpc_lambda_sg"
  description = "Security group for lambdas made for use by DEV VPC resources."
  vpc_id      = aws_vpc.DEV-VPC.id

  dynamic "egress" {
    iterator = cidr
    for_each = var.database_subnet_cidrs
    content {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      cidr_blocks = [cidr.value]
    }
  }

  tags = {
    Name = "DEV VPC Lambda SG"
  }
}

resource "aws_security_group" "db_sg" {
  name        = "dev_vpc_db_sg"
  description = "Security group for DEV VPC"
  vpc_id      = aws_vpc.DEV-VPC.id

  dynamic "egress" {
    iterator = cidr
    for_each = var.database_subnet_cidrs
    content {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      cidr_blocks = [cidr.value]
    }
  }

  tags = {
    Name = "DEV VPC DB SG"
  }
}

# DB Subnet Group
# DB SNG ----------------------------------------------
resource "aws_db_subnet_group" "test_db_subnet_group" {
  name        = "test_db_subnet_group"
  description = "DEV VPC DB Subnet Group"

  subnet_ids = [for subnet in aws_subnet.test_db_01_subnet : subnet.id]
}