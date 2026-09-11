provider "aws" {
  region = var.aws_region
}

# 1. Registro de Contenedores (ECR)
resource "aws_ecr_repository" "api_repo" {
  name = "telemetry-api"
  force_delete = true # Facilita destruir el entorno de pruebas localmente
}

# 2. Rol de ejecución para lambda
resource "aws_iam_role" "lambda_exec_role" {
  name = "telemetry_lambda_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
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

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# 3. Computo Serverless (Lambda)
resource "aws_lambda_function" "api_lambda" {
  function_name = "telemetry-api-function"
  role          = aws_iam_role.lambda_exec_role.arn
  package_type  = "Image"
  image_uri     = var.image_uri
  timeout       = 10

  # Ignorar cambios en la URI para que Terraform no intente degradar la imagen en futuras ejecuciones manuales
  lifecycle {
    ignore_changes = [image_uri]
  }
}

# 4. Acceso HTTP nativo (Lambda Function URL)
resource "aws_lambda_function_url" "api_url" {
  function_name = aws_lambda_function.api_lambda.function_name
  authorization_type = "NONE"
}

# Permiso para invocar la función Lambda desde cualquier origen
resource "aws_lambda_permission" "url_permission" {
  statement_id           = "AllowPublicInvoke"
  action                 = "lambda:InvokeFunctionUrl"
  function_name          = aws_lambda_function.api_lambda.function_name
  principal              = "*"
  function_url_auth_type = "NONE"
}
