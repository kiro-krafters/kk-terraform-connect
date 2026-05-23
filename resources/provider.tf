terraform {
  backend "s3" {}
}

# Default - No assume_role needed, GitHub Actions already authenticated
provider "aws" {
  region = var.region
}

# Primary: us-east-1
provider "aws" {
  alias  = "primary_region"
  region = "us-east-1"
}

# Secondary: us-west-2
provider "aws" {
  alias  = "secondary_region"
  region = "us-west-2"
}

provider "awscc" {
  region = var.region
}
