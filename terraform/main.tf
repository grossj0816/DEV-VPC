terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "value"
    key            = "value"
    region         = "value"
    dynamodb_table = "value"
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
}

# LAMBDA SUBNETS
resource "aws_subnet" "lambda_subnet" {
}

# DATABASE SUBNETS
resource "aws_subnet" "test_db_01_subnet" {
}

# INTERNET GATEWAY
resource "aws_internet_gateway" "igw" {
}

# ELASTIC IP ADDRESS
resource "aws_eip" "nat_eip" {
}

# NAT Gateway
resource "aws_nat_gateway" "nat" {
}


# ROUTE TABLES -----------------------------------------
resource "aws_route_table" "public_table" {
}

resource "aws_route_table" "private_table" {
}

# ROUTES ------------------------------------------------
resource "aws_route" "public_route" {
}

resource "aws_route" "private_route" {
}

# Route Table Associations
# RTA --------------------------------------------------
resource "aws_route_table_association" "public_assoc" {
}

resource "aws_route_table_associaion" "lambda_assoc" {
}

resource "aws_route_table_association" "database_assoc" {
}

# Security Groups
# SGS ------------------------------------------------
resource "aws_security_group" "lambda_sg" {
}

resource "aws_security_group" "db_sg" {
}

# DB Subnet Group
# DBSNG ----------------------------------------------
resource "aws_db_subnet_group" "test_db_subnet_group" {
}