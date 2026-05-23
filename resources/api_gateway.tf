# 1. Create the REST API
module "sms_sender_api" {
  source        = "git@github.com:CA-Bridge/ccaas-terraform-modules-wrapper.git//terraform-aws-apigwv1-wrapper?ref=v1.0.8"
  create_api    = true # <-- MUST BE UNCOMMENTED TO CREATE THE API
  name          = format("%s-apig-sms-sender-%s-%s", var.company_prefix, local.region_prefix, var.env)
  description   = "REST API for SMS Sender Application"
  authorization = "NONE"
  types         = "REGIONAL"
  stage_name    = local.stage_name
  # create_method = true # <-- MUST BE UNCOMMENTED TO CREATE THE DEPLOYMENT/STAGE
  # enable_logs = true # <-- MUST BE UNCOMMENTED TO ENABLE LOGS
  resource_paths = {
    "/" = {
      create_method = false
    }
  }
  tags = local.tags
}

module "sms_sender_api_resource" {
  source                = "git@github.com:CA-Bridge/ccaas-terraform-modules-wrapper.git//terraform-aws-apigwv1-wrapper?ref=v1.0.8"
  description           = "REST API for SMS Sender Application - Create Proxy Resource"
  create_api            = false
  rest_api_id           = module.sms_sender_api.apigatewayv1_api_id
  create_child_resource = true
  stage_name            = local.stage_name

  resource_paths = {
    "{proxy+}" = {
      create_method = false
      parent_id     = module.sms_sender_api.apigatewayv1_root_resource_id
    }
  }
  tags = local.tags

}


# 2 Configure the Resource (/) with ANY method and Lambda Integration
module "sms_sender_api_any_method" {
  depends_on  = [module.sms_backend_lambda, module.sms_sender_api_resource, module.sms_sender_api]
  source      = "git@github.com:CA-Bridge/ccaas-terraform-modules-wrapper.git//terraform-aws-apigwv1-wrapper?ref=v1.0.8"
  description = "REST API for SMS Sender Application - ANY method and Lambda Integration"
  # Flag to skip API creation/stage creation since it's done in module "sms_sender_api"
  create_api            = false
  create_child_resource = false
  create_method         = false # Re-deploy to include this method
  # IDs from the created API
  rest_api_id            = module.sms_sender_api.apigatewayv1_api_id
  rest_api_execution_arn = module.sms_sender_api.apigatewayv1_api_execution_arn
  stage_name             = local.stage_name
  resource_paths = {
    "/" = {
      resource_id             = module.sms_sender_api.apigatewayv1_root_resource_id
      create_method           = true
      lambda_arn              = module.sms_backend_lambda.lambda_function_arn
      http_method             = "ANY"
      integration_http_method = "POST"
      type                    = "AWS_PROXY"
      authorization           = "NONE"
      add_invoke              = true
      authorization           = "NONE"
      authorizer_id           = null
      request_parameters      = {}
      integration_parameters  = {}
      integration_response_configuration = {
        status_code         = "200"
        response_parameters = {}
      }
    }
    "{proxy+}" = {
      resource_id             = module.sms_sender_api_resource.child_resource_ids["{proxy+}"]
      create_method           = true
      lambda_arn              = module.sms_backend_lambda.lambda_function_arn
      http_method             = "ANY"
      integration_http_method = "POST"
      type                    = "AWS_PROXY"
      authorization           = "NONE"
      add_invoke              = true
      authorization           = "NONE"
      authorizer_id           = null
      request_parameters      = {}
      integration_parameters  = {}
      integration_response_configuration = {
        status_code = "200"
        response_parameters = {
          "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
          "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'"
          "method.response.header.Access-Control-Allow-Origin"  = "'*'"
        }
      }
    }
  }
  method_response_params = {
    "/" = {
      status_code         = "200"
      response_parameters = {}
      response_models = {
        "application/json" = "Empty"
      }
    }
    "{proxy+}" = {
      status_code = "200"
      response_parameters = {
        "method.response.header.Access-Control-Allow-Headers" = true
        "method.response.header.Access-Control-Allow-Methods" = true
        "method.response.header.Access-Control-Allow-Origin"  = true
      }
      response_models = {
        "application/json" = "Empty"
      }
    }
  }
  tags = local.tags
}

# 3 Add CORS (OPTIONS) Method on the Resource
module "sms_sender_api_cors_method" {
  depends_on = [module.sms_sender_api]
  source     = "git@github.com:CA-Bridge/ccaas-terraform-modules-wrapper.git//terraform-aws-apigwv1-wrapper?ref=v1.0.8"

  create_api             = false
  create_child_resource  = false
  create_method          = false
  description            = "API Gateway for Backend Application. REST API"
  stage_name             = local.stage_name
  rest_api_id            = module.sms_sender_api.apigatewayv1_api_id
  rest_api_execution_arn = module.sms_sender_api.apigatewayv1_api_execution_arn

  resource_paths = {
    "/" = {
      resource_id            = module.sms_sender_api.apigatewayv1_root_resource_id
      create_method          = true
      lambda_arn             = null
      http_method            = "OPTIONS"
      type                   = "MOCK"
      authorization          = "NONE"
      add_invoke             = false
      request_parameters     = {}
      integration_parameters = {}

      integration_response_configuration = {
        status_code = "200"
        response_parameters = {
          "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
          "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'"
          "method.response.header.Access-Control-Allow-Origin"  = "'*'"
        }
      }
    }
    "{proxy+}" = {
      resource_id            = module.sms_sender_api_resource.child_resource_ids["{proxy+}"]
      create_method          = true
      lambda_arn             = null
      http_method            = "OPTIONS"
      type                   = "MOCK"
      authorization          = "NONE"
      add_invoke             = false
      request_parameters     = {}
      integration_parameters = {}

      integration_response_configuration = {
        status_code = "200"
        response_parameters = {
          "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
          "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'"
          "method.response.header.Access-Control-Allow-Origin"  = "'*'"
        }
      }
    }
  }

  method_response_params = {
    "/" = {
      status_code = "200"
      response_parameters = {
        "method.response.header.Access-Control-Allow-Headers" = true
        "method.response.header.Access-Control-Allow-Methods" = true
        "method.response.header.Access-Control-Allow-Origin"  = true
      }
      response_models = {
        "application/json" = "Empty"
      }
    }
    "{proxy+}" = {
      status_code = "200"
      response_parameters = {
        "method.response.header.Access-Control-Allow-Headers" = true
        "method.response.header.Access-Control-Allow-Methods" = true
        "method.response.header.Access-Control-Allow-Origin"  = true
      }
      response_models = {
        "application/json" = "Empty"
      }
    }
  }

  tags = local.tags
}

# 4. Trigger Deployment (LAST MODULE)
module "sms_sender_api_deployment" {
  depends_on = [
    module.sms_sender_api_any_method,
    module.sms_sender_api_cors_method
  ]
  source                 = "git@github.com:CA-Bridge/ccaas-terraform-modules-wrapper.git//terraform-aws-apigwv1-wrapper?ref=v1.0.8"
  description            = "Trigger deployment after all methods are created"
  create_api             = false
  create_child_resource  = false
  create_method          = true # <-- ONLY THIS MODULE DEPLOYS
  enable_logs            = true # <-- MUST BE UNCOMMENTED TO ENABLE LOGS
  rest_api_id            = module.sms_sender_api.apigatewayv1_api_id
  rest_api_execution_arn = module.sms_sender_api.apigatewayv1_api_execution_arn
  stage_name             = local.stage_name

  resource_paths = {} # Empty - just triggering deployment

  tags = local.tags
}

# 1. Create the REST API
module "case_management_api" {
  source        = "git@github.com:CA-Bridge/ccaas-terraform-modules-wrapper.git//terraform-aws-apigwv1-wrapper?ref=v1.0.8"
  create_api    = true # <-- MUST BE UNCOMMENTED TO CREATE THE API
  name          = format("%s-apig-case-management-%s-%s", var.company_prefix, local.region_prefix, var.env)
  description   = "REST API for Case Management Application"
  authorization = "NONE"
  types         = "REGIONAL"
  stage_name    = local.stage_name
  # create_method = true # <-- MUST BE UNCOMMENTED TO CREATE THE DEPLOYMENT/STAGE
  # enable_logs = true # <-- MUST BE UNCOMMENTED TO ENABLE LOGS
  resource_paths = {
    "/" = {
      create_method = false
    }
  }
  tags = local.tags
}

module "case_management_api_resource" {
  source                = "git@github.com:CA-Bridge/ccaas-terraform-modules-wrapper.git//terraform-aws-apigwv1-wrapper?ref=v1.0.8"
  description           = "REST API for Case Management Application - Create Proxy Resource"
  create_api            = false
  rest_api_id           = module.case_management_api.apigatewayv1_api_id
  create_child_resource = true
  stage_name            = local.stage_name

  resource_paths = {
    "api" = {
      create_method = false
      parent_id     = module.case_management_api.apigatewayv1_root_resource_id
    }
  }
  tags = local.tags

}

module "case_management_api_resource_proxy" {
  source                = "git@github.com:CA-Bridge/ccaas-terraform-modules-wrapper.git//terraform-aws-apigwv1-wrapper?ref=v1.0.8"
  description           = "REST API for Case Management Application - Create Proxy Resource"
  create_api            = false
  rest_api_id           = module.case_management_api.apigatewayv1_api_id
  create_child_resource = true
  stage_name            = local.stage_name

  resource_paths = {
    "{proxy+}" = {
      create_method = false
      parent_id     = module.case_management_api_resource.child_resource_ids["api"]
    }
  }
  tags = local.tags

}

# 2 Configure the Resource (/) with ANY method and Lambda Integration
module "case_management_api_any_method" {
  depends_on  = [module.case_management_lambda, module.case_management_api_resource, module.case_management_api]
  source      = "git@github.com:CA-Bridge/ccaas-terraform-modules-wrapper.git//terraform-aws-apigwv1-wrapper?ref=v1.0.8"
  description = "REST API for Case Management Application - ANY method and Lambda Integration"
  # Flag to skip API creation/stage creation since it's done in module "case_management_api"
  create_api            = false
  create_child_resource = false
  create_method         = false # Re-deploy to include this method
  # IDs from the created API
  rest_api_id            = module.case_management_api.apigatewayv1_api_id
  rest_api_execution_arn = module.case_management_api.apigatewayv1_api_execution_arn
  stage_name             = local.stage_name
  resource_paths = {
    "api" = {
      resource_id             = module.case_management_api_resource.child_resource_ids["api"]
      create_method           = true
      lambda_arn              = module.case_management_lambda.lambda_function_arn
      http_method             = "ANY"
      integration_http_method = "POST"
      type                    = "AWS_PROXY"
      authorization           = "NONE"
      add_invoke              = true
      authorization           = "NONE"
      authorizer_id           = null
      request_parameters      = {}
      integration_parameters  = {}
      integration_response_configuration = {
        status_code         = "200"
        response_parameters = {}
      }
    }
    "{proxy+}" = {
      resource_id             = module.case_management_api_resource_proxy.child_resource_ids["{proxy+}"]
      create_method           = true
      lambda_arn              = module.case_management_lambda.lambda_function_arn
      http_method             = "ANY"
      integration_http_method = "POST"
      type                    = "AWS_PROXY"
      authorization           = "NONE"
      add_invoke              = true
      authorization           = "NONE"
      authorizer_id           = null
      request_parameters      = {}
      integration_parameters  = {}
      integration_response_configuration = {
        status_code = "200"
        response_parameters = {
          "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
          "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'"
          "method.response.header.Access-Control-Allow-Origin"  = "'*'"
        }
      }
    }
  }
  method_response_params = {
    "api" = {
      status_code         = "200"
      response_parameters = {}
      response_models = {
        "application/json" = "Empty"
      }
    }
    "{proxy+}" = {
      status_code = "200"
      response_parameters = {
        "method.response.header.Access-Control-Allow-Headers" = true
        "method.response.header.Access-Control-Allow-Methods" = true
        "method.response.header.Access-Control-Allow-Origin"  = true
      }
      response_models = {
        "application/json" = "Empty"
      }
    }
  }
  tags = local.tags
}

# 3 Add CORS (OPTIONS) Method on the Resource
module "case_management_api_cors_method" {
  depends_on = [module.case_management_api]
  source     = "git@github.com:CA-Bridge/ccaas-terraform-modules-wrapper.git//terraform-aws-apigwv1-wrapper?ref=v1.0.8"

  create_api             = false
  create_child_resource  = false
  create_method          = false
  description            = "API Gateway for Backend Application. REST API"
  stage_name             = local.stage_name
  rest_api_id            = module.case_management_api.apigatewayv1_api_id
  rest_api_execution_arn = module.case_management_api.apigatewayv1_api_execution_arn

  resource_paths = {
    "api" = {
      resource_id            = module.case_management_api_resource.child_resource_ids["api"]
      create_method          = true
      lambda_arn             = null
      http_method            = "OPTIONS"
      type                   = "MOCK"
      authorization          = "NONE"
      add_invoke             = false
      request_parameters     = {}
      integration_parameters = {}

      integration_response_configuration = {
        status_code = "200"
        response_parameters = {
          "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
          "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'"
          "method.response.header.Access-Control-Allow-Origin"  = "'*'"
        }
      }
    }
    "{proxy+}" = {
      resource_id            = module.case_management_api_resource_proxy.child_resource_ids["{proxy+}"]
      create_method          = true
      lambda_arn             = null
      http_method            = "OPTIONS"
      type                   = "MOCK"
      authorization          = "NONE"
      add_invoke             = false
      request_parameters     = {}
      integration_parameters = {}

      integration_response_configuration = {
        status_code = "200"
        response_parameters = {
          "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
          "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'"
          "method.response.header.Access-Control-Allow-Origin"  = "'*'"
        }
      }
    }
  }

  method_response_params = {
    "api" = {
      status_code = "200"
      response_parameters = {
        "method.response.header.Access-Control-Allow-Headers" = true
        "method.response.header.Access-Control-Allow-Methods" = true
        "method.response.header.Access-Control-Allow-Origin"  = true
      }
      response_models = {
        "application/json" = "Empty"
      }
    }
    "{proxy+}" = {
      status_code = "200"
      response_parameters = {
        "method.response.header.Access-Control-Allow-Headers" = true
        "method.response.header.Access-Control-Allow-Methods" = true
        "method.response.header.Access-Control-Allow-Origin"  = true
      }
      response_models = {
        "application/json" = "Empty"
      }
    }
  }

  tags = local.tags
}

# 4. Trigger Deployment (LAST MODULE)
module "case_management_api_deployment" {
  depends_on = [
    module.case_management_api_any_method,
    module.case_management_api_cors_method
  ]
  source                 = "git@github.com:CA-Bridge/ccaas-terraform-modules-wrapper.git//terraform-aws-apigwv1-wrapper?ref=v1.0.8"
  description            = "Trigger deployment after all methods are created"
  create_api             = false
  create_child_resource  = false
  create_method          = true # <-- ONLY THIS MODULE DEPLOYS
  enable_logs            = true # <-- MUST BE UNCOMMENTED TO ENABLE LOGS
  rest_api_id            = module.case_management_api.apigatewayv1_api_id
  rest_api_execution_arn = module.case_management_api.apigatewayv1_api_execution_arn
  stage_name             = local.stage_name

  resource_paths = {} # Empty - just triggering deployment

  tags = local.tags
}

