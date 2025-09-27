######################################################################
######################## IMPORTANT ###################################
# We are using an Academic version of AWS, so please check the following:
#
# 1. Credentials Location:
#    - macOS/Linux:   ~/.aws/credentials
#    - Windows:       C:\Users\<Your-Username>\.aws\credentials
#
# 2. Profile:
#    - We are using the "default" profile.
#    - Make sure you have created this profile in your credentials file.
#
# 3. Required fields for your profile (for regular AWS accounts):
#    - aws_access_key_id
#    - aws_secret_access_key
#    - aws_session_token
#
# 4. Check the README to understand how to set up your credentials file.
#
# Without these, Terraform will not be able to connect to AWS.
######################################################################

# The terraform block defines global settings for Terraform itself
# This is where we specify version constraints and required providers
terraform {
  required_version = ">= 1.5.0" # Specify the minimum version of Terraform required to run this configuration

  # Define which providers (plugins) this configuration needs to interact with cloud platforms
  required_providers {
    aws = {                     # The AWS provider allows Terraform to manage AWS resources
      source  = "hashicorp/aws" # Source tells Terraform where to download the provider from
      version = "~> 5.0"        # Version constraint ensures we use a compatible version of the AWS provider
    }
  }
}

# The provider block configures the AWS provider with specific settings
provider "aws" {
  profile = "default"      # Profile specifies which AWS credentials profile to use from ~/.aws/credentials
  region  = var.aws_region # Region specifies which AWS region to deploy resources into
}

# Variables allow you to parameterize your Terraform configuration
variable "aws_region" {
  description = "AWS region to deploy into" # Human-readable description of what this variable is for
  type        = string                      # Data type constraint - this variable must be a string
  default     = "us-east-1"
}
