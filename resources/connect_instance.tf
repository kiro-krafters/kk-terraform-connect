module "amazon_connect" {
  source                             = "git@github.com:CA-Bridge/ccaas-terraform-modules-wrapper.git//terraform-aws-amazonconnect-wrapper?ref=v1.0.0"
  region_prefix                      = local.region_prefix
  company_prefix                     = var.company_prefix
  env                                = var.env
  create_instance                    = var.create_instance
  instance_id                        = var.create_instance ? null : data.aws_connect_instance.amazon_connect[0].id
  instance_identity_management_type  = "SAML"
  instance_storage_configs           = local.instance_storage_configs
  multi_party_conference_enabled     = true
  instance_contact_flow_logs_enabled = true
  tags                               = local.tags
}

module "amazon_connect_associations" {
  count                = var.is_primary ? 1 : 0
  source               = "git@github.com:CA-Bridge/ccaas-terraform-modules-wrapper.git//terraform-aws-amazonconnect-wrapper?ref=v1.0.0"
  create_instance      = false
  instance_id          = local.connect_instance_id
  region_prefix        = local.region_prefix
  company_prefix       = var.company_prefix
  env                  = var.env
  hours_of_operations  = local.hours_of_operations
  queues               = local.queues
  routing_profiles     = local.routing_profiles
  contact_flow_modules = local.contact_flow_modules
  contact_flows        = local.sms_contact_flows

  lambda_function_associations = {
    case_event_enrichment_lambda    = module.case_event_enrichment_lambda.lambda_function_arn
    intake_dialogue_function_lambda = module.intake_dialogue_function_lambda.lambda_function_arn
    get_non_closed_cases_lambda     = module.get_non_closed_cases_lambda.lambda_function_arn
    vm_voicemail_timestamper_lambda = module.vm_voicemail_timestamper_lambda.lambda_function_arn
    inbound_sms_tracking_lambda     = module.inbound_sms_tracking.lambda_function_arn
  }

  depends_on = [module.amazon_connect, module.lex_bot]
}

module "amazon_connect_voice_flow" {
  count           = var.is_primary ? 1 : 0
  source          = "git@github.com:CA-Bridge/ccaas-terraform-modules-wrapper.git//terraform-aws-amazonconnect-wrapper?ref=v1.0.0"
  create_instance = false
  instance_id     = local.connect_instance_id
  region_prefix   = local.region_prefix
  company_prefix  = var.company_prefix
  env             = var.env

  contact_flows = local.voice_contact_flows


  depends_on = [module.amazon_connect, module.amazon_connect_associations]
}
