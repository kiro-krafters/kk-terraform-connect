bucket         = "cb-s3-tf-state-backend-prd"
key            = "us-east-1/ccaas-terraform-connect/terraform.tfstate"
region         = "us-east-1"
dynamodb_table = "cb-dyndb-tf-state-backend-lock-prd"
encrypt        = true
