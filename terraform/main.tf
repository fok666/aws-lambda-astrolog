terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# IAM role for Lambda function
resource "aws_iam_role" "lambda_role" {
  name = "${var.function_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Attach basic execution policy
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda Layer for Astrolog
resource "aws_lambda_layer_version" "astrolog_layer" {
  filename            = var.layer_package_path
  layer_name          = "astrolog-binary"
  compatible_runtimes = ["python3.9", "python3.10", "python3.11", "python3.12"]
  description         = "Astrolog binary and supporting files for AWS Lambda"
  
  source_code_hash = filebase64sha256(var.layer_package_path)
}

# Create deployment package for Lambda function
data "archive_file" "lambda_package" {
  type        = "zip"
  source_dir  = "${path.module}/../lambda"
  output_path = "${path.module}/lambda_function.zip"
}

# Lambda Function
resource "aws_lambda_function" "astrolog_function" {
  filename         = data.archive_file.lambda_package.output_path
  function_name    = var.function_name
  role            = aws_iam_role.lambda_role.arn
  handler         = "lambda_function.lambda_handler"
  source_code_hash = data.archive_file.lambda_package.output_base64sha256
  runtime         = var.python_runtime
  timeout         = var.timeout
  memory_size     = var.memory_size

  layers = [aws_lambda_layer_version.astrolog_layer.arn]

  environment {
    variables = {
      DEBUG = "false"
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic_execution
  ]
}

# Lambda Function URL (optional, for direct HTTP invocation)
resource "aws_lambda_function_url" "astrolog_function_url" {
  count = var.enable_function_url ? 1 : 0
  
  function_name      = aws_lambda_function.astrolog_function.function_name
  authorization_type = "NONE"  # Change to "AWS_IAM" for authenticated access
}
