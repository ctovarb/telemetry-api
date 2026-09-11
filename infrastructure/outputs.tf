output "api_endpoint" {
  description = "URL del endpoint de la API"
  value       = aws_lambda_function_url.api_url.function_url
}
