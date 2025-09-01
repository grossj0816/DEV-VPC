variable "public_subnet_cidrs" {
  type      = list(string)
  default = ["10.0.7.0/24", "10.0.8.0/24"]
}

variable "lambda_subnet_cidrs" {
  type      = list(string)
  default = ["10.0.9.0/24", "10.0.10.0/24"]
}

variable "database_subnet_cidrs" {
  type      = list(string)
  sensitive = ["10.0.11.0/24", "10.0.12.0/24"]

}

variable "azs" {
  type      = list(string)
  default = ["us-east-1d", "us-east-1e", "us-east-1f"]
}

variable "username" {
  type      = string
  sensitive = true
}

variable "password" {
  type      = string
  sensitive = true

}
