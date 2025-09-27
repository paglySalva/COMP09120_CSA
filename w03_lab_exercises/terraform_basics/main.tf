############################################
# Data sources
############################################
# Data sources allow you to query existing AWS resources that weren't created by this Terraform configuration
# This is useful when you want to reference existing infrastructure or get information from AWS

# Query the default VPC in this AWS region
# Every AWS account has a default VPC in each region for easy resource deployment
data "aws_vpc" "default" {
  default = true # The "default = true" filter finds the VPC marked as the default VPC in this region
}

# Query all subnets that belong to the default VPC
# Subnets are network segments within a VPC where you can place AWS resources
data "aws_subnets" "default" {
  # Use a filter to find subnets that belong to our default VPC
  filter {
    name   = "vpc-id"                  # Filter by the vpc-id attribute
    values = [data.aws_vpc.default.id] # Use the ID of the default VPC we queried earlier  
  }
}

# Query the latest Ubuntu 22.04 LTS AMI (Amazon Machine Image)
# AMIs are pre-configured virtual machine templates used to launch EC2 instances
data "aws_ami" "ubuntu_2204" {
  most_recent = true             # This ensures we always use the latest patched version
  owners      = ["099720109477"] # Canonical's official AWS account ID

  # Filter to find the specific Ubuntu version we want
  filter {
    name   = "name"                                                      # Filter by the AMI name
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"] # Ubuntu 22.04 LTS (Jammy) server AMIs
  }
}

############################################
# Security group (allow SSH for EIC)
############################################
# Security groups act as virtual firewalls for your EC2 instances
# They control inbound and outbound traffic at the instance level

# Create a security group resource to define firewall rules
resource "aws_security_group" "eic_ssh" {
  name        = "allow-ssh-for-eic"                       # Unique name for this security group within the region
  description = "Allow SSH (22) for EC2 Instance Connect" # Human-readable description of what this security group does 
  vpc_id      = data.aws_vpc.default.id                   # Security groups must belong to a specific VPC

  # INBOUND RULES (ingress): What traffic is allowed INTO the instance
  # This rule allows SSH connections from anywhere on the internet
  # ⚠️  WARNING: In production, you should restrict this to specific IP addresses

  ingress {
    description = "SSH" # Description of this rule
    from_port   = 22    # Port range: 22 is the standard port for SSH
    to_port     = 22
    protocol    = "tcp"         # Protocol: TCP is used for SSH connections
    cidr_blocks = ["0.0.0.0/0"] # "0.0.0.0/0" means "any IP address" (very permissive!)
  }

  # OUTBOUND RULES (egress): What traffic the instance can send OUT
  # This rule allows all outbound traffic (very permissive)
  egress {
    from_port = 0 # Port range: 0 means "any port" 
    to_port   = 0
    protocol  = "-1" # Protocol: -1 means "all protocols"

    # Allow outbound traffic to any IP address
    # This lets the instance download updates, connect to APIs, etc.
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Tags are key-value pairs for organizing and identifying resources
  tags = {
    Name = "allow-ssh-for-eic" # Tag the security group with a name
  }
}

############################################
# EC2 instance
############################################

resource "aws_instance" "my_vm" {
  ami           = data.aws_ami.ubuntu_2204.id
  instance_type = "t2.micro"

  # Place in default VPC/subnet and ensure a public IP
  subnet_id                   = data.aws_subnets.default.ids[0]
  vpc_security_group_ids      = [aws_security_group.eic_ssh.id]
  associate_public_ip_address = true

  # Install EC2 Instance Connect on Ubuntu
  user_data = <<-CLOUD
    #!/bin/bash
    set -eux
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -y
    apt-get install -y ec2-instance-connect
    systemctl restart ssh
  CLOUD

  tags = {
    Name = "Pablo EC2 instance - 1"
  }
}

############################################
# Outputs
############################################

output "public_ip" {
  value       = aws_instance.my_vm.public_ip
  description = "Public IPv4 address"
}

output "public_dns" {
  value       = aws_instance.my_vm.public_dns
  description = "Public DNS name"
}
