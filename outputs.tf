# This will output the API endpoints
output "Endpoint-url" {
  value       = aws_api_gateway_deployment.prod-api.invoke_url
  description = "EndPoint API url"
}
