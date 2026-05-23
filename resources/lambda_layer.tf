module "intake_dialogue_function_lambda_layer" {
  source                  = "git@github.com:CA-Bridge/ccaas-terraform-modules-wrapper.git//terraform-aws-lambda-wrapper?ref=v1.0.0"
  create                  = { layer = true }
  layer_name              = format("%s-lmda-intake-dialogue-function-layer-%s-%s", var.company_prefix, local.region_prefix, var.env)
  description             = "A layer for intake dialogue function."
  compatible_runtimes     = ["nodejs22.x"]
  local_existing_package  = "./lambda_layer/cb-intake-dialogue-function-layer-v2.zip"
  ignore_source_code_hash = true
  tags                    = local.tags
}

module "get_non_closed_cases_lambda_layer" {
  source                  = "git@github.com:CA-Bridge/ccaas-terraform-modules-wrapper.git//terraform-aws-lambda-wrapper?ref=v1.0.0"
  create                  = { layer = true }
  layer_name              = format("%s-lmda-get-non-closed-cases-layer-%s-%s", var.company_prefix, local.region_prefix, var.env)
  description             = "A layer for get non closed cases function."
  compatible_runtimes     = ["nodejs22.x"]
  local_existing_package  = "./lambda_layer/cb-get-non-closed-cases-layer-v2.zip"
  ignore_source_code_hash = true
  tags                    = local.tags
}

module "delete_all_cases_lambda_layer" {
  source                  = "git@github.com:CA-Bridge/ccaas-terraform-modules-wrapper.git//terraform-aws-lambda-wrapper?ref=v1.0.0"
  create                  = { layer = true }
  layer_name              = format("%s-lmda-delete-all-cases-layer-%s-%s", var.company_prefix, local.region_prefix, var.env)
  description             = "A layer for delete all cases function."
  compatible_runtimes     = ["nodejs22.x"]
  local_existing_package  = "./lambda_layer/cb-delete-all-cases-layer-v2.zip"
  ignore_source_code_hash = true
  tags                    = local.tags
}

module "connect_backup_lambda_layer" {
  source                  = "git@github.com:CA-Bridge/ccaas-terraform-modules-wrapper.git//terraform-aws-lambda-wrapper?ref=v1.0.0"
  create                  = { layer = true }
  layer_name              = format("%s-lmda-connect-backup-layer-%s-%s", var.company_prefix, local.region_prefix, var.env)
  description             = "A layer for connect backup function."
  compatible_runtimes     = ["nodejs22.x"]
  local_existing_package  = "./lambda_layer/cb-connect-backup-function-layer-v2.zip"
  ignore_source_code_hash = true
  tags                    = local.tags
}

module "sms_backend_lambda_layer" {
  source                  = "git@github.com:CA-Bridge/ccaas-terraform-modules-wrapper.git//terraform-aws-lambda-wrapper?ref=v1.0.0"
  create                  = { layer = true }
  layer_name              = format("%s-lmda-sms-backend-layer-%s-%s", var.company_prefix, local.region_prefix, var.env)
  description             = "A layer for sms backend function."
  compatible_runtimes     = ["nodejs24.x"]
  local_existing_package  = "./lambda_layer/cb-sms-referral-backend-layer-v2.zip"
  ignore_source_code_hash = true
  tags                    = local.tags
}

module "inbound_sms_tracking_layer" {
  source                  = "git@github.com:CA-Bridge/ccaas-terraform-modules-wrapper.git//terraform-aws-lambda-wrapper?ref=v1.0.0"
  create                  = { layer = true }
  layer_name              = format("%s-lmda-inbound-sms-tracking-layer-%s-%s", var.company_prefix, local.region_prefix, var.env)
  description             = "A layer for inbound sms tracking function."
  compatible_runtimes     = ["nodejs24.x"]
  local_existing_package  = "./lambda_layer/cb-inbound-sms-tracking-layer-v2.zip"
  ignore_source_code_hash = true
  tags                    = local.tags
}

module "vm_recording_processor_lambda_layer" {
  source                  = "git@github.com:CA-Bridge/ccaas-terraform-modules-wrapper.git//terraform-aws-lambda-wrapper?ref=v1.0.0"
  create                  = { layer = true }
  layer_name              = format("%s-lmda-vm-recording-processor-layer-%s-%s", var.company_prefix, local.region_prefix, var.env)
  description             = "A layer for VM recording processor function."
  compatible_runtimes     = ["python3.13"]
  local_existing_package  = "./lambda_layer/vm-recording-processor-layer-v4.zip"
  ignore_source_code_hash = true
  tags                    = local.tags
}

module "vm_packager_lambda_layer" {
  source                  = "git@github.com:CA-Bridge/ccaas-terraform-modules-wrapper.git//terraform-aws-lambda-wrapper?ref=v1.0.0"
  create                  = { layer = true }
  layer_name              = format("%s-lmda-vm-packager-layer-%s-%s", var.company_prefix, local.region_prefix, var.env)
  description             = "A layer for VM Lambda functions (Packager & Presigner)."
  compatible_runtimes     = ["python3.13"]
  local_existing_package  = "./lambda_layer/vm-recording-processor-layer-v4.zip"
  ignore_source_code_hash = true
  tags                    = local.tags
}

module "case_management_lambda_layer" {
  source                  = "git@github.com:CA-Bridge/ccaas-terraform-modules-wrapper.git//terraform-aws-lambda-wrapper?ref=v1.0.0"
  create                  = { layer = true }
  layer_name              = format("%s-lmda-case-management-layer-%s-%s", var.company_prefix, local.region_prefix, var.env)
  description             = "A layer for case management lambda."
  compatible_runtimes     = ["nodejs22.x"]
  local_existing_package  = "./lambda_layer/cb-case-management-layer-v2.zip"
  ignore_source_code_hash = true
  tags                    = local.tags
}
