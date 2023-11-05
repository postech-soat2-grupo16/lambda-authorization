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

## Infra lambda
resource "aws_lambda_function" "lambda" {
  function_name    = "lambda-authorization"
  handler          = "lambda.main"
  runtime          = "python3.8"
  filename         = data.archive_file.code.output_path
  source_code_hash = data.archive_file.code.output_base64sha256
  role             = var.lambda_execution_role
  timeout          = 120
  #layers           = [aws_lambda_layer_version.layer.arn]
  description = "Lamda para autenticar"

  vpc_config {
    subnet_ids         = [var.subnet_a, var.subnet_b]
    security_group_ids = [var.security_group_lambda]
  }

  environment {
    variables = {
      "SECRET_KEY_AUTH" = var.secret_name_auth
    }
  }
}
