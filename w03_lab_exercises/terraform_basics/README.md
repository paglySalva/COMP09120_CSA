# COMP09120 - Cloud Services & Architectures (Week 03)

This guide will walk you through the fundamentals of Infrastructure as Code (IaC) using Terraform to provision AWS resources. We'll use the existing configuration files in this directory to learn core Terraform concepts and commands.

## What is Terraform?

Terraform is an open-source tool that allows you to define, provision, and manage cloud infrastructure using code. Instead of manually clicking through the AWS console, you write configuration files that describe what resources you want, and Terraform creates them for you.

## Prerequisites

Before starting, ensure you have completed previous steps of the lab session on Aula:
- Terraform installed (check with `terraform version`)
- AWS credentials configured in `~/.aws/credentials`
- Access to an AWS account

## Step 2: Terraform providers

Terraform implements a modular approach in its application architecture. The Terraform binary you have installed is the core module required to perform core Terraform functions. Any operation that involves invoking cloud provider APIs requires additional provider modules.

In our case, Terraform needs to instantiate the AWS provider module to work with AWS services. Let's examine our provider configuration.

Open the `provider.tf` file and examine its contents:

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

provider "aws" {
  profile = "default"
  region  = var.aws_region
}

variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}
```

**Understanding the configuration:**

- The `terraform` block specifies the minimum Terraform version and required providers
- The `required_providers` block tells Terraform to download the AWS provider from HashiCorp's registry
- The version constraint `~> 5.0` means any version >= 5.0.0 and < 6.0.0
- The `provider "aws"` block configures how Terraform connects to AWS using your credentials profile
- The `variable` block makes the AWS region configurable

Now run the following command to initialize your Terraform project:

```bash
terraform init
```

You should see output similar to:
```
Initializing the backend...
Initializing provider plugins...
- Finding hashicorp/aws versions matching "~> 5.0"...
- Installing hashicorp/aws v5.x.x...
- Installed hashicorp/aws v5.x.x (signed by HashiCorp)

Terraform has been successfully initialized!
```

This command downloads the AWS provider plugin and creates a `.terraform` directory with the provider binaries.

## Step 3: Terraform resources

Now let's examine how to define AWS resources. Open the `main.tf` file to see our resource declarations.

The main components in our configuration are:

### Data Sources
Data sources allow you to fetch information about existing AWS resources:

```hcl
data "aws_vpc" "default" {
  default = true
}

data "aws_ami" "ubuntu_2204" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}
```

### Security Group Resource
```hcl
resource "aws_security_group" "eic_ssh" {
  name        = "allow-ssh-for-eic"
  description = "Allow SSH (22) for EC2 Instance Connect"
  vpc_id      = data.aws_vpc.default.id
  # ... ingress and egress rules
}
```

### EC2 Instance Resource
```hcl
resource "aws_instance" "my_vm" {
  ami           = data.aws_ami.ubuntu_2204.id
  instance_type = "t2.micro"
  subnet_id     = data.aws_subnets.default.ids[0]
  vpc_security_group_ids = [aws_security_group.eic_ssh.id]
  # ... additional configuration
}
```

**Key concepts:**
- `resource` blocks define infrastructure components to be created
- `"aws_instance"` is the resource type (an EC2 instance)
- `"my_vm"` is the local identifier for this resource
- Resource attributes define the properties of the resource
- References like `data.aws_ami.ubuntu_2204.id` create dependencies between resources

## Step 4: Terraform CLI commands

We have created the Terraform code to provision our AWS resources, but we haven't actually provisioned them yet. Let's explore the most important Terraform CLI commands that help us understand the resource lifecycle managed by Terraform.

### 1. Format (fmt)

Proper code formatting improves readability and maintainability. The `terraform fmt` command automatically formats your Terraform code.

```bash
terraform fmt
```

**What this does:**
- Formats all `.tf` files in the current directory
- Standardizes indentation and spacing
- Outputs the names of files that were reformatted

Run this command now - you should see output showing which files were formatted.

### 2. Validate

Before proceeding, let's validate our configuration:

```bash
terraform validate
```

**What this does:**
- Checks configuration files for syntax errors
- Validates resource references and required arguments
- Confirms the configuration is syntactically correct

You should see "Success! The configuration is valid."

### 3. Plan

The plan command shows you what Terraform will do before actually doing it:

```bash
terraform plan
```

**What this does:**
- Compares your desired state (configuration) with the current state
- Shows what resources will be created, modified, or destroyed
- Provides a preview without making any changes

**Understanding the output:**
- Resources marked with `+` will be created
- Resources marked with `-` will be destroyed  
- Resources marked with `~` will be modified
- The plan summary shows how many resources will be added, changed, or destroyed

### 4. Apply

Now let's actually create the infrastructure:

```bash
terraform apply
```

**What this does:**
- Shows the execution plan (same as `terraform plan`)
- Asks for confirmation before proceeding
- Creates the resources in AWS
- Updates the Terraform state file

**Expected process:**
1. Terraform will display the plan
2. You'll be prompted: "Do you want to perform these actions?"
3. Type `yes` to confirm
4. Terraform will create the resources and show the progress
5. Upon completion, you'll see the output values (public IP, DNS name)

### 5. Show

After applying, inspect your infrastructure:

```bash
terraform show
```

**What this does:**
- Displays the current state of all managed resources
- Shows all resource attributes and their current values
- Useful for understanding what was actually created

### 6. Destroy

When you're finished with the lab, clean up the resources:

```bash
terraform destroy
```

**What this does:**
- Shows what resources will be destroyed
- Asks for confirmation before proceeding
- Removes all resources defined in your configuration
- Updates the state file to reflect the destroyed resources

**⚠️ Important:** Always run `terraform destroy` when finished to avoid AWS charges!


## Summary

Congratulations! You've successfully completed the Terraform basics tutorial. Here's what you've accomplished:

✅ **Step 2 - Providers:** Understood how Terraform uses providers to interact with cloud services  
✅ **Step 3 - Resources:** Learned how to define AWS resources using Terraform configuration  
✅ **Step 4 - CLI Commands:** Mastered the essential Terraform workflow commands  


### Key Terraform Commands You've Learned

| Command | Purpose |
|---------|----------|
| `terraform init` | Initialize working directory and download providers |
| `terraform fmt` | Format configuration files |
| `terraform validate` | Validate configuration syntax |
| `terraform plan` | Preview changes before applying |
| `terraform apply` | Create/update infrastructure |
| `terraform show` | Display current state |
| `terraform destroy` | Destroy all managed resources |

### The Terraform Workflow

1. **Write** configuration files (`.tf`)
2. **Initialize** the working directory (`terraform init`)
3. **Plan** changes (`terraform plan`)
4. **Apply** changes (`terraform apply`)
5. **Manage** and update as needed
6. **Destroy** when finished (`terraform destroy`)

## Troubleshooting

### Common Issues and Solutions

**AWS Credentials Not Found:**
```
Error: No valid credential sources found for AWS Provider
```
- Check that `~/.aws/credentials` exists and contains your credentials
- Verify the profile name matches what's in `provider.tf`
- Ensure your AWS session hasn't expired

**Provider Version Conflicts:**
```
Error: Inconsistent dependency lock file
```
- Run `terraform init -upgrade` to update providers
- This typically happens when you change provider versions

**Permission Denied:**
```
Error: UnauthorizedOperation
```
- Your AWS account may lack necessary permissions
- Contact your instructor or AWS administrator
- Try a different AWS region if specified in course materials

**Resources Already Exist:**
```
Error: resource already exists
```
- Someone else might be using the same resource names
- Change resource names in your configuration
- Or use `terraform import` to manage existing resources

## Next Steps

Now that you understand Terraform basics, consider exploring:

- **Terraform Modules:** Reusable infrastructure components
- **Remote State:** Storing state files in cloud storage
- **Terraform Cloud:** Collaboration and automation platform
- **More AWS Resources:** RDS databases, load balancers, auto-scaling groups
- **Multi-environment Deployments:** Using workspaces or separate configurations

## Additional Resources

- [Terraform Documentation](https://www.terraform.io/docs)
- [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Registry](https://registry.terraform.io/) - Find providers and modules
- [AWS Free Tier](https://aws.amazon.com/free/) - Understand cost implications

---

**Remember:** Infrastructure as Code is a powerful approach that brings software development best practices to infrastructure management. Keep practicing and experimenting to become proficient with Terraform!


---

**Remember:** Always run `terraform destroy` when you're finished to avoid unnecessary AWS charges!
