variable "public_subnet_cidrs" {
  type      = list(string)
  sensitive = true
}

variable "lambda_subnet_cidrs" {
  type      = list(string)
  sensitive = true
}

variable "database_subnet_cidrs" {
  type      = list(string)
  sensitive = true
}

variable "azs" {
  type      = list(string)
  sensitive = true
}

variable "username" {
  type      = string
  sensitive = true
}

variable "password" {
  type      = string
  sensitive = true

}
