# Declare the AWS provider configuration
provider "aws" {
  # Specify the AWS region using a variable
  region = var.k8-region
  
  # Use default AWS credentials from ~/.aws/credentials
  shared_credentials_files = ["~/.aws/credentials"]
  profile                 = "default"
}

