# Terraform Basics Tutorial

Welcome to your first Terraform lab! This tutorial will guide you through the fundamentals of Infrastructure as Code (IaC) using Terraform to create AWS resources.

## What is Terraform?

Terraform is an open-source tool that allows you to define, provision, and manage cloud infrastructure using code. Instead of manually clicking through the AWS console, you write configuration files that describe what resources you want, and Terraform creates them for you.

## Prerequisites

Before starting, make sure you have:

1. **Terraform installed** - Check with `terraform version`
2. **AWS credentials configured** - Your AWS academic account credentials should be set up in `~/.aws/credentials`

## Lab Overview

In this lab, you will:
- Learn about Terraform providers
- Understand how to define AWS resources
- Practice essential Terraform commands
- Create and manage an EC2 instance

## Step 1: Understanding the Provider Configuration

Open the `provider.tf` file and examine it carefully. This file contains three important sections:

### 1.1 The `terraform` Block
```hcl
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

**What this does:**
- Sets the minimum Terraform version required
- Declares that we need the AWS provider
- Specifies which version of the AWS provider to use

### 1.2 The `provider` Block
```hcl
provider "aws" {
  profile = "default"
  region  = var.aws_region
}
```

**What this does:**
- Configures how Terraform connects to AWS
- Uses the "default" profile from your AWS credentials file
- Sets the AWS region where resources will be created

### 1.3 The `variable` Block
```hcl
variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}
```

**What this does:**
- Defines a variable to make the configuration flexible
- Sets a default AWS region
- Can be overridden when running Terraform commands

## Step 2: Understanding Resource Definition

Open the `main.tf` file and look at the EC2 instance resource:

```hcl
resource "aws_instance" "my_vm" {
  ami           = data.aws_ami.ubuntu_2204.id
  instance_type = "t2.micro"
  # ... more configuration
}
```

**Key concepts:**
- `resource` - Tells Terraform this is a resource to create
- `"aws_instance"` - The resource type (an EC2 instance)
- `"my_vm"` - The local name for this resource (you choose this)
- Inside the block are the resource's properties

## Step 3: Essential Terraform Commands

Now let's learn the core Terraform workflow commands. Run these commands in order:

### 3.1 Initialize Terraform

```bash
terraform init
```

**What this does:**
- Downloads the AWS provider plugin
- Sets up the working directory
- Creates a `.terraform` directory with provider files

**Expected output:**
- You should see "Terraform has been successfully initialized!"

### 3.2 Format Your Code

```bash
terraform fmt
```

**What this does:**
- Automatically formats your `.tf` files
- Ensures consistent indentation and spacing
- Good practice to run before committing code

### 3.3 Validate Your Configuration

```bash
terraform validate
```

**What this does:**
- Checks your configuration files for syntax errors
- Ensures resource references are valid
- Doesn't check if resources can actually be created

### 3.4 Plan Your Changes

```bash
terraform plan
```

**What this does:**
- Shows you what Terraform will create, modify, or destroy
- Like a "preview" before making actual changes
- No resources are created yet!

**What to look for:**
- Resources marked with `+` will be created
- Resources marked with `-` will be destroyed
- Resources marked with `~` will be modified

### 3.5 Apply Your Changes

```bash
terraform apply
```

**What this does:**
- Actually creates the resources in AWS
- Will show the plan again and ask for confirmation
- Type `yes` to proceed

**Expected outcome:**
- An EC2 instance will be created in your AWS account
- You'll see output values (IP address, DNS name)

### 3.6 Inspect Your State

```bash
terraform show
```

**What this does:**
- Shows the current state of your infrastructure
- Lists all resources and their properties

## Step 4: Making Changes

Try making a simple change to practice the workflow:

1. **Edit the instance tag** in `main.tf`:
   ```hcl
   tags = {
     Name = "My Updated EC2 instance"
   }
   ```

2. **Plan the change:**
   ```bash
   terraform plan
   ```
   You should see the tag will be updated.

3. **Apply the change:**
   ```bash
   terraform apply
   ```

## Step 5: Cleaning Up

When you're done with the lab, it's important to clean up to avoid charges:

```bash
terraform destroy
```

**What this does:**
- Destroys all resources created by this Terraform configuration
- Will show what will be destroyed and ask for confirmation
- Type `yes` to proceed

**⚠️ Important:** Always run `terraform destroy` when finished with lab exercises!

## Common Commands Summary

| Command | Purpose |
|---------|---------|
| `terraform init` | Initialize working directory |
| `terraform fmt` | Format configuration files |
| `terraform validate` | Check configuration syntax |
| `terraform plan` | Preview changes |
| `terraform apply` | Create/update resources |
| `terraform show` | Display current state |
| `terraform destroy` | Delete all resources |

## Troubleshooting

### AWS Credentials Issues
If you get authentication errors:
1. Check that `~/.aws/credentials` exists and contains your credentials
2. Verify the profile name matches what's in `provider.tf`
3. Make sure your AWS session hasn't expired

### Permission Issues
If you get "Access Denied" errors:
- Your AWS academic account might not have permissions for certain actions
- Try a different AWS region if specified in your course materials

### Resource Already Exists
If resources already exist:
- Someone else might be using the same names
- Change the resource names in your configuration
- Or import existing resources (advanced topic)

## What You've Learned

By completing this lab, you've learned:

✅ How to configure Terraform providers  
✅ How to define AWS resources in code  
✅ The essential Terraform workflow commands  
✅ How to plan, apply, and destroy infrastructure  
✅ Basic troubleshooting techniques  

## Next Steps

Now that you understand the basics:
- Experiment with different instance types
- Try adding more resources
- Learn about Terraform modules
- Explore more AWS resources

## Additional Resources

- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Language Documentation](https://www.terraform.io/language)
- [AWS Free Tier](https://aws.amazon.com/free/)

---

**Remember:** Always run `terraform destroy` when you're finished to avoid unnecessary AWS charges!
