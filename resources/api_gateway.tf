# ========================================
# API Gateway for KK Backend
# ========================================

# API Gateway REST API
resource "aws_api_gateway_rest_api" "kk_backend_api" {
  name        = "${var.env}-kk-backend"
  description = "KK Backend API Gateway"
  
  endpoint_configuration {
    types = ["EDGE"]
  }

  tags = local.tags
}

# API Gateway Deployment
resource "aws_api_gateway_deployment" "kk_backend_deployment" {
  rest_api_id = aws_api_gateway_rest_api.kk_backend_api.id

  depends_on = [
    aws_api_gateway_integration.health_integration,
    aws_api_gateway_integration.portal_chat_start_integration,
    # Add other integrations as dependencies
  ]

  lifecycle {
    create_before_destroy = true
  }
}

# API Gateway Stage
resource "aws_api_gateway_stage" "kk_backend_stage" {
  deployment_id = aws_api_gateway_deployment.kk_backend_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.kk_backend_api.id
  stage_name    = var.env

  tags = local.tags
}

# API Gateway Resources
resource "aws_api_gateway_resource" "health" {
  rest_api_id = aws_api_gateway_rest_api.kk_backend_api.id
  parent_id   = aws_api_gateway_rest_api.kk_backend_api.root_resource_id
  path_part   = "health"
}

resource "aws_api_gateway_resource" "portal" {
  rest_api_id = aws_api_gateway_rest_api.kk_backend_api.id
  parent_id   = aws_api_gateway_rest_api.kk_backend_api.root_resource_id
  path_part   = "portal"
}

resource "aws_api_gateway_resource" "portal_chat" {
  rest_api_id = aws_api_gateway_rest_api.kk_backend_api.id
  parent_id   = aws_api_gateway_resource.portal.id
  path_part   = "chat"
}

resource "aws_api_gateway_resource" "portal_chat_start" {
  rest_api_id = aws_api_gateway_rest_api.kk_backend_api.id
  parent_id   = aws_api_gateway_resource.portal_chat.id
  path_part   = "start"
}

# API Gateway Methods
resource "aws_api_gateway_method" "health_get" {
  rest_api_id   = aws_api_gateway_rest_api.kk_backend_api.id
  resource_id   = aws_api_gateway_resource.health.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "health_options" {
  rest_api_id   = aws_api_gateway_rest_api.kk_backend_api.id
  resource_id   = aws_api_gateway_resource.health.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# API Gateway Integrations
resource "aws_api_gateway_integration" "health_integration" {
  rest_api_id             = aws_api_gateway_rest_api.kk_backend_api.id
  resource_id             = aws_api_gateway_resource.health.id
  http_method             = aws_api_gateway_method.health_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.kk_health_lambda.lambda_function_invoke_arn
}

resource "aws_api_gateway_integration" "health_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.kk_backend_api.id
  resource_id = aws_api_gateway_resource.health.id
  http_method = aws_api_gateway_method.health_options.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

# API Gateway Method Responses
resource "aws_api_gateway_method_response" "health_options_200" {
  rest_api_id = aws_api_gateway_rest_api.kk_backend_api.id
  resource_id = aws_api_gateway_resource.health.id
  http_method = aws_api_gateway_method.health_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

# API Gateway Integration Responses
resource "aws_api_gateway_integration_response" "health_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.kk_backend_api.id
  resource_id = aws_api_gateway_resource.health.id
  http_method = aws_api_gateway_method.health_options.http_method
  status_code = aws_api_gateway_method_response.health_options_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,X-Amz-User-Agent,X-Amzn-Trace-Id'"
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,GET'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

# Lambda Permissions for API Gateway
resource "aws_lambda_permission" "health_api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.kk_health_lambda.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.kk_backend_api.execution_arn}/*/*"
}

# Note: Additional API Gateway resources, methods, integrations, and permissions
# should be created for all other Lambda functions following the same pattern.
# This includes portal chat endpoints, admin endpoints, AI endpoints, etc.
