variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "lambda_execution_role" {
  description = "Execution Role Lambda"
  type        = string
  sensitive   = true
  default     = ""
}

variable "vpc_id" {
  type    = string
  default = ""
}

variable "subnet_a" {
  type    = string
  default = ""
}

variable "subnet_b" {
  type    = string
  default = ""
}

variable "secret_name_auth" {
  type      = string
  sensitive = true
  default   = ""
}
