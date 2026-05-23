# Local values for DynamoDB tables

locals {
  # Region prefix mapping
  region_prefix_map = {
    "us-east-1" = "use1"
    "us-east-2" = "use2"
    "us-west-1" = "usw1"
    "us-west-2" = "usw2"
  }

  region_prefix = local.region_prefix_map[var.region]

  # Common tags for all resources
  tags = {
    Company     = var.company
    Project     = var.project
    Environment = var.env
    Region      = var.region
    ManagedBy   = "Terraform"
  }
}
