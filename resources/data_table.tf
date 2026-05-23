module "data_table_stack" {
  count  = var.is_primary ? 1 : 0
  source = "git@github.com:CA-Bridge/ccaas-terraform-modules-wrapper.git//terraform-aws-cloudformation-wrapper?ref=v1.0.0"
  name   = "${var.company_prefix}-data-table-${local.region_prefix}-${var.env}"

  template_url = "https://${var.company_prefix}-s3-cfn-stack-templates-${local.region_prefix}-${var.env}.s3.${var.region}.amazonaws.com/${local.region_prefix}/datatable/cb-data-table-${local.file_hash_map["data_table.yaml"]}.yaml"
  parameters = {
    pConnectInstanceArn = "arn:aws:connect:${var.region}:${var.account_number}:instance/${local.connect_instance_id}"
  }
  depends_on = [module.s3_cfn_objects]
}
