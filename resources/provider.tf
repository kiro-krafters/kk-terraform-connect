terraform {
  backend "s3" {}
}

# Default
provider "aws" {
  region = var.region

  assume_role {
    role_arn = "arn:aws:iam::${var.account_number}:role/${var.role_name}"
  }
}

# Primary: us-east-1
provider "aws" {
  alias  = "primary_region"
  region = "us-east-1"

  assume_role {
    role_arn = "arn:aws:iam::${var.account_number}:role/${var.role_name}"
  }
}

# Secondary: us-west-2
provider "aws" {
  alias  = "secondary_region"
  region = "us-west-2"

  assume_role {
    role_arn = "arn:aws:iam::${var.account_number}:role/${var.role_name}"
  }
}

provider "awscc" {
  region = var.region

  assume_role = {
    role_arn = "arn:aws:iam::${var.account_number}:role/${var.role_name}"
  }
}
