# Create AWS key pair (only if create_key_pair is true)
resource "aws_key_pair" "student_keypair" {
  count      = var.create_key_pair ? 1 : 0
  key_name   = var.key_name
  public_key = var.public_key_content
}

# Data source to get existing key pair (when create_key_pair is false)
data "aws_key_pair" "existing" {
  count    = var.create_key_pair ? 0 : 1
  key_name = var.key_name
}

# Data source to find the latest Ubuntu 20.04 LTS AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Provision the Kubernetes master node
resource "aws_instance" "k8-master" {
  ami                         = data.aws_ami.ubuntu.id               # Latest Ubuntu 20.04 LTS AMI
  instance_type               = var.instance_type                    # Instance type specified in variables
  key_name                    = var.create_key_pair ? aws_key_pair.student_keypair[0].key_name : data.aws_key_pair.existing[0].key_name
  associate_public_ip_address = true                                 # Associate a public IP
  vpc_security_group_ids      = [aws_security_group.k8cluster-sg.id] # Use the Kubernetes security group
  subnet_id                   = aws_subnet.subnet1.id                # Use the specified subnet

  # Use a startup script for configuring the master node
  user_data = file("startup-master.sh")

  tags = {
    Name = "kubernetes-master"
    Role = "master"
    Cluster = "kubernetes"
  }

  depends_on = [aws_main_route_table_association.kubernetes-set-rt-to-vpc]
}

# Provision Kubernetes worker nodes
resource "aws_instance" "k8-node" {
  count                       = var.workers-count                    # Create the specified number of worker nodes
  ami                         = data.aws_ami.ubuntu.id               # Latest Ubuntu 20.04 LTS AMI
  instance_type               = var.instance_type                    # Instance type specified in variables
  key_name                    = var.create_key_pair ? aws_key_pair.student_keypair[0].key_name : data.aws_key_pair.existing[0].key_name
  associate_public_ip_address = true                                 # Associate a public IP
  vpc_security_group_ids      = [aws_security_group.k8cluster-sg.id] # Use the Kubernetes security group
  subnet_id                   = aws_subnet.subnet1.id                # Use the specified subnet

  # Use a startup script for configuring the worker nodes
  user_data = file("startup-worker.sh")

  tags = {
    Name = join("-", ["kubernetes-node", count.index + 1]) # Create unique names for each node
    Role = "worker"
    Cluster = "kubernetes"
  }
  # ensure required network settings are deployed beforehand
  depends_on = [aws_main_route_table_association.kubernetes-set-rt-to-vpc]
}
