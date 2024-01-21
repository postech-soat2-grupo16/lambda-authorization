provider "aws" {
  region = var.aws_region
}

#Configuração do Terraform State
terraform {
  backend "s3" {
    bucket = "terraform-state-soat"
    key    = "infra-lambda-authorization/terraform.tfstate"
    region = "us-east-1"

    dynamodb_table = "terraform-state-soat-locking"
    encrypt        = true
  }
}

## .zip do código
data "archive_file" "code" {
  type        = "zip"
  source_dir  = "../src/code"
  output_path = "../src/code/code.zip"
}

#Security Group Lambda Authorization
resource "aws_security_group" "security_group_authorization_lambda_ecs" {
  name_prefix = "security_group_authorization_lambda_ecs"
  description = "SG for Lambda Authoriation"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 8000
    to_port   = 8000
    protocol  = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    infra   = "lambda"
    service = "gateway"
    Name    = "security_group_authorization_lambda_ecs"
  }
}

## Infra lambda Authorization
resource "aws_lambda_function" "lambda_authorization" {
  function_name    = "lambda-authorization"
  handler          = "lambda.main"
  runtime          = "python3.8"
  filename         = data.archive_file.code.output_path
  source_code_hash = data.archive_file.code.output_base64sha256
  role             = var.lambda_execution_role
  timeout          = 120
  description      = "Lamda para autorizar"

  vpc_config {
    subnet_ids         = [var.subnet_a, var.subnet_b]
    security_group_ids = [aws_security_group.security_group_authorization_lambda_ecs.id]
  }

  environment {
    variables = {
      "SECRET_KEY_AUTH" = var.secret_name_auth
    }
  }

    tags = {
    infra   = "lambda"
    service = "authorization"
  }
}
