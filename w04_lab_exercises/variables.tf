# Define a variable for the default region where the infrastructure will be provisioned
variable "k8-region" {
  type        = string
  description = "Default Region"
}

# Define a variable for the CIDR block of the main VPC
variable "k8-vpc-cidr" {
  type        = string
  description = "CIDR block of main VPC"
}

# Define a variable for the CIDR block of the first subnet
variable "k8-subnet-cidr" {
  type        = string
  description = "CIDR block of the first subnet"
}

# Define a variable for the external IP range
variable "external_ip" {
  type        = string
  description = "Our external IP"
  default     = "0.0.0.0/0" # Default value set to allow all IPs
}

# Define a variable for the instance type used for both Kubernetes nodes and master
variable "instance_type" {
  type        = string
  description = "Instance type for Kubernetes nodes and master"
  default     = "t2.micro" # Default instance type set to t2.micro
}

# Define a variable for the number of Kubernetes worker nodes
variable "workers-count" {
  type        = number
  default     = 2
  description = "Number of Kubernetes worker nodes"
}

# Define a variable for the AWS key pair name
# Students can either use an existing key pair or create a new one
variable "key_name" {
  type        = string
  description = "Name of the AWS key pair (use 'vockey' for AWS Academy default, or specify your own)"
}

# Define a variable to determine whether to create a new key pair or use existing
variable "create_key_pair" {
  type        = bool
  description = "Set to true to create a new key pair, false to use existing AWS key pair"
  default     = false
}

# Define a variable for the SSH public key content (only needed if creating new key pair)
variable "public_key_content" {
  type        = string
  description = "Content of your SSH public key (only needed if create_key_pair is true)"
  default     = ""
}
