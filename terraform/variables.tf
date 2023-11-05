variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "lambda_execution_role" {
  description = "Execution Role Lambda"
  type = string
  sensitive = true
}

variable "subnet_a" {
  type = string
  default = "value"
}

variable "subnet_b" {
  type = string
  default = "value"
}

variable "security_group_lambda" {
  type = string
  default = "value"
}

variable "secret_name_auth" {
  type = string
  sensitive = true
}
