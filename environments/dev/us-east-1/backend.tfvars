bucket         = "kk-s3-tf-state-backend-dev"
key            = "us-east-1/ccaas-terraform-connect/terraform.tfstate"
region         = "us-east-1"
dynamodb_table = "kk-dyndb-tf-state-backend-lock-dev"
encrypt        = true
