# ========================================
# Complete API Gateway Configuration for KK Backend
# ========================================

# This file contains all API Gateway resources, methods, integrations, and permissions
# for the KK Backend application. It follows the structure defined in the CloudFormation template.

# ========================================
# Portal Chat Endpoints
# ========================================

# POST /portal/chat/start
resource "aws_api_gateway_method" "portal_chat_start_post" {
  rest_api_id   = aws_api_gateway_rest_api.kk_backend_api.id
  resource_id   = aws_api_gateway_resource.portal_chat_start.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "portal_chat_start_integration" {
  rest_api_id             = aws_api_gateway_rest_api.kk_backend_api.id
  resource_id             = aws_api_gateway_resource.portal_chat_start.id
  http_method             = aws_api_gateway_method.portal_chat_start_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.kk_portal_chat_start_lambda.lambda_function_invoke_arn
}

resource "aws_lambda_permission" "portal_chat_start_api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.kk_portal_chat_start_lambda.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.kk_backend_api.execution_arn}/*/*"
}

# OPTIONS /portal/chat/start (CORS)
resource "aws_api_gateway_method" "portal_chat_start_options" {
  rest_api_id   = aws_api_gateway_rest_api.kk_backend_api.id
  resource_id   = aws_api_gateway_resource.portal_chat_start.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "portal_chat_start_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.kk_backend_api.id
  resource_id = aws_api_gateway_resource.portal_chat_start.id
  http_method = aws_api_gateway_method.portal_chat_start_options.http_method
  type        = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "portal_chat_start_options_200" {
  rest_api_id = aws_api_gateway_rest_api.kk_backend_api.id
  resource_id = aws_api_gateway_resource.portal_chat_start.id
  http_method = aws_api_gateway_method.portal_chat_start_options.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "portal_chat_start_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.kk_backend_api.id
  resource_id = aws_api_gateway_resource.portal_chat_start.id
  http_method = aws_api_gateway_method.portal_chat_start_options.http_method
  status_code = aws_api_gateway_method_response.portal_chat_start_options_200.status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,X-Amz-User-Agent,X-Amzn-Trace-Id'"
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,POST'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

# ========================================
# Portal Chat Session Endpoints
# ========================================

# Resource: /portal/chat/{sessionId}
resource "aws_api_gateway_resource" "portal_chat_session" {
  rest_api_id = aws_api_gateway_rest_api.kk_backend_api.id
  parent_id   = aws_api_gateway_resource.portal_chat.id
  path_part   = "{sessionId}"
}

# Resource: /portal/chat/{sessionId}/message
resource "aws_api_gateway_resource" "portal_chat_message" {
  rest_api_id = aws_api_gateway_rest_api.kk_backend_api.id
  parent_id   = aws_api_gateway_resource.portal_chat_session.id
  path_part   = "message"
}

# POST /portal/chat/{sessionId}/message
resource "aws_api_gateway_method" "portal_chat_send_message_post" {
  rest_api_id   = aws_api_gateway_rest_api.kk_backend_api.id
  resource_id   = aws_api_gateway_resource.portal_chat_message.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "portal_chat_send_message_integration" {
  rest_api_id             = aws_api_gateway_rest_api.kk_backend_api.id
  resource_id             = aws_api_gateway_resource.portal_chat_message.id
  http_method             = aws_api_gateway_method.portal_chat_send_message_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.kk_portal_chat_send_message_lambda.lambda_function_invoke_arn
}

resource "aws_lambda_permission" "portal_chat_send_message_api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.kk_portal_chat_send_message_lambda.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.kk_backend_api.execution_arn}/*/*"
}

# Resource: /portal/chat/{sessionId}/messages
resource "aws_api_gateway_resource" "portal_chat_messages" {
  rest_api_id = aws_api_gateway_rest_api.kk_backend_api.id
  parent_id   = aws_api_gateway_resource.portal_chat_session.id
  path_part   = "messages"
}

# GET /portal/chat/{sessionId}/messages
resource "aws_api_gateway_method" "portal_chat_get_messages_get" {
  rest_api_id   = aws_api_gateway_rest_api.kk_backend_api.id
  resource_id   = aws_api_gateway_resource.portal_chat_messages.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "portal_chat_get_messages_integration" {
  rest_api_id             = aws_api_gateway_rest_api.kk_backend_api.id
  resource_id             = aws_api_gateway_resource.portal_chat_messages.id
  http_method             = aws_api_gateway_method.portal_chat_get_messages_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.kk_portal_chat_get_messages_lambda.lambda_function_invoke_arn
}

resource "aws_lambda_permission" "portal_chat_get_messages_api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.kk_portal_chat_get_messages_lambda.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.kk_backend_api.execution_arn}/*/*"
}

# DELETE /portal/chat/{sessionId}
resource "aws_api_gateway_method" "portal_chat_end_delete" {
  rest_api_id   = aws_api_gateway_rest_api.kk_backend_api.id
  resource_id   = aws_api_gateway_resource.portal_chat_session.id
  http_method   = "DELETE"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "portal_chat_end_integration" {
  rest_api_id             = aws_api_gateway_rest_api.kk_backend_api.id
  resource_id             = aws_api_gateway_resource.portal_chat_session.id
  http_method             = aws_api_gateway_method.portal_chat_end_delete.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.kk_portal_chat_end_lambda.lambda_function_invoke_arn
}

resource "aws_lambda_permission" "portal_chat_end_api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.kk_portal_chat_end_lambda.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.kk_backend_api.execution_arn}/*/*"
}

# ========================================
# Portal Callback Endpoint
# ========================================

# Resource: /portal/callback
resource "aws_api_gateway_resource" "portal_callback" {
  rest_api_id = aws_api_gateway_rest_api.kk_backend_api.id
  parent_id   = aws_api_gateway_resource.portal.id
  path_part   = "callback"
}

# POST /portal/callback
resource "aws_api_gateway_method" "portal_callback_post" {
  rest_api_id   = aws_api_gateway_rest_api.kk_backend_api.id
  resource_id   = aws_api_gateway_resource.portal_callback.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "portal_callback_integration" {
  rest_api_id             = aws_api_gateway_rest_api.kk_backend_api.id
  resource_id             = aws_api_gateway_resource.portal_callback.id
  http_method             = aws_api_gateway_method.portal_callback_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.kk_portal_callback_request_lambda.lambda_function_invoke_arn
}

resource "aws_lambda_permission" "portal_callback_api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.kk_portal_callback_request_lambda.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.kk_backend_api.execution_arn}/*/*"
}

# ========================================
# Portal Contact Endpoint
# ========================================

# Resource: /portal/contact
resource "aws_api_gateway_resource" "portal_contact" {
  rest_api_id = aws_api_gateway_rest_api.kk_backend_api.id
  parent_id   = aws_api_gateway_resource.portal.id
  path_part   = "contact"
}

# POST /portal/contact
resource "aws_api_gateway_method" "portal_contact_post" {
  rest_api_id   = aws_api_gateway_rest_api.kk_backend_api.id
  resource_id   = aws_api_gateway_resource.portal_contact.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "portal_contact_integration" {
  rest_api_id             = aws_api_gateway_rest_api.kk_backend_api.id
  resource_id             = aws_api_gateway_resource.portal_contact.id
  http_method             = aws_api_gateway_method.portal_contact_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.kk_portal_contact_submit_lambda.lambda_function_invoke_arn
}

resource "aws_lambda_permission" "portal_contact_api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.kk_portal_contact_submit_lambda.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.kk_backend_api.execution_arn}/*/*"
}

# ========================================
# AI Endpoints
# ========================================

# Resource: /ai
resource "aws_api_gateway_resource" "ai" {
  rest_api_id = aws_api_gateway_rest_api.kk_backend_api.id
  parent_id   = aws_api_gateway_rest_api.kk_backend_api.root_resource_id
  path_part   = "ai"
}

# Resource: /ai/message
resource "aws_api_gateway_resource" "ai_message" {
  rest_api_id = aws_api_gateway_rest_api.kk_backend_api.id
  parent_id   = aws_api_gateway_resource.ai.id
  path_part   = "message"
}

# POST /ai/message
resource "aws_api_gateway_method" "ai_message_post" {
  rest_api_id   = aws_api_gateway_rest_api.kk_backend_api.id
  resource_id   = aws_api_gateway_resource.ai_message.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "ai_message_integration" {
  rest_api_id             = aws_api_gateway_rest_api.kk_backend_api.id
  resource_id             = aws_api_gateway_resource.ai_message.id
  http_method             = aws_api_gateway_method.ai_message_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.kk_ai_message_lambda.lambda_function_invoke_arn
}

resource "aws_lambda_permission" "ai_message_api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.kk_ai_message_lambda.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.kk_backend_api.execution_arn}/*/*"
}

# Resource: /ai/transfer
resource "aws_api_gateway_resource" "ai_transfer" {
  rest_api_id = aws_api_gateway_rest_api.kk_backend_api.id
  parent_id   = aws_api_gateway_resource.ai.id
  path_part   = "transfer"
}

# POST /ai/transfer
resource "aws_api_gateway_method" "ai_transfer_post" {
  rest_api_id   = aws_api_gateway_rest_api.kk_backend_api.id
  resource_id   = aws_api_gateway_resource.ai_transfer.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "ai_transfer_integration" {
  rest_api_id             = aws_api_gateway_rest_api.kk_backend_api.id
  resource_id             = aws_api_gateway_resource.ai_transfer.id
  http_method             = aws_api_gateway_method.ai_transfer_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.kk_ai_transfer_lambda.lambda_function_invoke_arn
}

resource "aws_lambda_permission" "ai_transfer_api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.kk_ai_transfer_lambda.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.kk_backend_api.execution_arn}/*/*"
}

# Resource: /ai/bedrock
resource "aws_api_gateway_resource" "ai_bedrock" {
  rest_api_id = aws_api_gateway_rest_api.kk_backend_api.id
  parent_id   = aws_api_gateway_resource.ai.id
  path_part   = "bedrock"
}

# Resource: /ai/bedrock/message
resource "aws_api_gateway_resource" "ai_bedrock_message" {
  rest_api_id = aws_api_gateway_rest_api.kk_backend_api.id
  parent_id   = aws_api_gateway_resource.ai_bedrock.id
  path_part   = "message"
}

# POST /ai/bedrock/message
resource "aws_api_gateway_method" "ai_bedrock_message_post" {
  rest_api_id   = aws_api_gateway_rest_api.kk_backend_api.id
  resource_id   = aws_api_gateway_resource.ai_bedrock_message.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "ai_bedrock_message_integration" {
  rest_api_id             = aws_api_gateway_rest_api.kk_backend_api.id
  resource_id             = aws_api_gateway_resource.ai_bedrock_message.id
  http_method             = aws_api_gateway_method.ai_bedrock_message_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.kk_ai_bedrock_message_lambda.lambda_function_invoke_arn
}

resource "aws_lambda_permission" "ai_bedrock_message_api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.kk_ai_bedrock_message_lambda.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.kk_backend_api.execution_arn}/*/*"
}

# ========================================
# Metrics Endpoint
# ========================================

# Resource: /metrics
resource "aws_api_gateway_resource" "metrics" {
  rest_api_id = aws_api_gateway_rest_api.kk_backend_api.id
  parent_id   = aws_api_gateway_rest_api.kk_backend_api.root_resource_id
  path_part   = "metrics"
}

# GET /metrics
resource "aws_api_gateway_method" "metrics_get" {
  rest_api_id   = aws_api_gateway_rest_api.kk_backend_api.id
  resource_id   = aws_api_gateway_resource.metrics.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "metrics_integration" {
  rest_api_id             = aws_api_gateway_rest_api.kk_backend_api.id
  resource_id             = aws_api_gateway_resource.metrics.id
  http_method             = aws_api_gateway_method.metrics_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.kk_get_metrics_lambda.lambda_function_invoke_arn
}

resource "aws_lambda_permission" "metrics_api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.kk_get_metrics_lambda.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.kk_backend_api.execution_arn}/*/*"
}

# Note: This file contains the core API Gateway endpoints.
# Additional endpoints for agents, queues, contacts, callbacks, bot stats, and admin functions
# should be added following the same pattern. Each endpoint requires:
# 1. Resource definition (if not already created)
# 2. Method definition (GET, POST, PUT, DELETE)
# 3. Integration with Lambda function
# 4. Lambda permission for API Gateway
# 5. OPTIONS method for CORS (if needed)
