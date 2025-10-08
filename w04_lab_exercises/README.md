# Kubernetes on AWS with Terraform (AWS Academy Compatible)

This Terraform configuration sets up a Kubernetes cluster on AWS with one master node and multiple worker nodes.

## Prerequisites

1. **AWS Academy Account** with active lab session
2. **Terraform** installed on your local machine (from previous lab)
3. **AWS CLI** installed on your local machine (from previous lab)
4. **SSH access** configured (see SSH Key Setup section below)

## AWS Academy Setup

### 1. Update AWS Credentials

Set your AWS Academy credentials as environment variables or in `~/.aws/credentials`:

```bash
[default]
aws_access_key_id="your-access-key"
aws_secret_access_key="your-secret-key"
aws_session_token="your-session-token"
```

**Important**: AWS Academy session tokens expire every few hours. You'll need to update these credentials from your AWS Academy lab when they expire.

### 2. SSH Key Configuration

**IMPORTANT**: This project has been updated to work with your AWS Academy SSH keys. You have two options:

**Option A (Recommended - AWS Academy Default Key):**
- The project is configured to use AWS Academy's default "vockey" key pair
- Download the PEM file from your AWS Academy lab interface ("Download PEM" button)
- Set proper permissions:
  - **macOS/Linux:** `chmod 400 /path/to/your/downloaded.pem`
  - **Windows:** Use PowerShell: `icacls "C:\path\to\labsuser.pem" /inheritance:r /grant:r "%USERNAME%":R`
- No changes needed in `terraform.tfvars`

**Option B (Advanced - Custom Key):**
- Create your own SSH key pair and configure it in `terraform.tfvars`
- See `SSH_KEY_SETUP.md` for detailed instructions

**📖 For complete SSH setup instructions, see `SSH_KEY_SETUP.md`**
**🪟 Windows users: See `WINDOWS_QUICK_GUIDE.md` for a quick start**

## Configuration

The `terraform.tfvars` file contains the following settings:

- **k8-region**: `us-east-1` (AWS Academy default region)
- **k8-vpc-cidr**: `10.0.0.0/16` (VPC network range)
- **k8-subnet-cidr**: `10.0.1.0/24` (Subnet range)
- **external_ip**: `0.0.0.0/0` (Allow SSH from anywhere - change for security)
- **instance_type**: `t2.medium` (Good performance for K8s)
- **workers-count**: `2` (Number of worker nodes)
- **key_name**: `vockey` (AWS key pair name - uses AWS Academy default)
- **create_key_pair**: `false` (Set to true if creating your own key pair)
- **public_key_content**: `""` (Your SSH public key content if create_key_pair is true)

## Deployment

### 1. Initialize Terraform
```bash
terraform init
```

### 2. Plan the Deployment
```bash
terraform plan
```

### 3. Apply the Configuration
```bash
terraform apply
```

Type `yes` when prompted to confirm the deployment.

## What Gets Created

- **VPC** with public subnet and internet gateway
- **Security Group** allowing SSH and internal traffic
- **1 Kubernetes Master Node** (t2.medium) - **fully configured and ready**
- **2 Kubernetes Worker Nodes** (t2.medium) - **ready to be manually joined**
- **SSH Key Pair** for access to instances
- **Kubernetes Master** with Calico networking installed

## After Deployment

### Get Instance IP Addresses
```bash
terraform output
```
You shold see something like this, take notes! It's your control plane node (Master) and worker node's IPs

```bash
Kubernetes-Master-Node-Public-IP = "54.198.xxx.xxx"
Kubernetes-Worker-nodes-Public-IP = {
  "i-00f9c210ea7ae3489" = "34.229.xxx.xxx"
  "i-09473540ee07c6506" = "54.210.xxx.xxx"
}
```

### Connect to Master Node
See previous step for the IP of your master node (The control Plane)

**For macOS/Linux users:**
```bash
ssh -i /path/to/your/downloaded.pem ubuntu@<MASTER_IP>
```

**For Windows users:**
```cmd
ssh -i "C:\path\to\your\downloaded.pem" ubuntu@<MASTER_IP>
```

**Note**: Use the PEM file you downloaded from AWS Academy, or your custom key if you created one.
**Windows users**: See `SSH_KEY_SETUP.md` for detailed permission setup instructions.

### Check Kubernetes Status
```bash
# On the master node
kubectl get nodes
kubectl get pods -A
```

### Join Worker Nodes to Cluster

1. **Generate join command on master node:**
```bash
# On the master node
sudo kubeadm token create --print-join-command
```

2. **Connect to each worker node and run the join command:**

**For macOS/Linux users:**
```bash
# Connect to worker node
ssh -i /path/to/your/downloaded.pem ubuntu@<WORKER_IP>
```

**For Windows users:**
```cmd
# Connect to worker node
ssh -i "C:\path\to\your\downloaded.pem" ubuntu@<WORKER_IP>
```

**Then run the join command (same for all platforms):**
```bash
# Run the join command (example output from step 1)
sudo kubeadm join <MASTER_IP>:6443 --token <TOKEN> --discovery-token-ca-cert-hash sha256:<HASH>
```

3. **Verify nodes joined on master:**
```bash
# On the master node
kubectl get nodes
```

When they have joined From the Master (control plane) you should see something like this:
```bash
NAME            STATUS   ROLES           AGE   VERSION
ip-10-0-1-194   Ready    <none>          17s   v1.28.15
ip-10-0-1-87    Ready    control-plane   17m   v1.28.15
ip-10-0-1-92    Ready    <none>          91s   v1.28.15
```

## Important Notes for AWS Academy

1. **Session Tokens Expire**: Update your `~/.aws/credentials` when your AWS Academy session expires
2. **Instance Limits**: AWS Academy accounts have EC2 instance limits (usually around 5-10 instances)
3. **No IAM Roles**: This configuration doesn't use IAM roles due to AWS Academy restrictions
4. **Cost Awareness**: Remember to destroy resources when done to avoid charges

## Troubleshooting

### Invalid Credentials Error
Update your AWS Academy credentials:
1. Go to AWS Academy Lab
2. Click "AWS Details"
3. Copy new credentials to `~/.aws/credentials`

### SSH Connection Issues
- Ensure security group allows SSH (port 22)
- Verify SSH key pair exists and has correct permissions
- Check public IP address in AWS console

### Kubernetes Issues
- Check startup script logs: `sudo tail -f /var/log/cloud-init-output.log`
- Verify containerd is running: `sudo systemctl status containerd`
- Check kubelet status: `sudo systemctl status kubelet`

## Cleanup

To destroy all resources:
```bash
terraform destroy
```

Type `yes` when prompted to confirm the destruction.

## File Structure

```
.
├── main.tf              # AWS provider configuration
├── variables.tf         # Variable definitions
├── terraform.tfvars     # Variable values (customize for your keys)
├── instances.tf         # EC2 instances and SSH keys
├── networks.tf          # VPC, subnets, routing
├── securitygroups.tf    # Security group rules
├── output.tf            # Output definitions
├── startup-master.sh    # Kubernetes master setup script
├── startup-worker.sh    # Kubernetes worker setup script
├── SSH_KEY_SETUP.md     # Detailed SSH key configuration guide
├── WINDOWS_QUICK_GUIDE.md # Quick SSH setup guide for Windows users
├── .gitignore           # Prevents committing sensitive files
└── README.md           # This file
```

## Security Considerations

- Change `external_ip` in `terraform.tfvars` to your specific IP address
- Use strong SSH key passphrases
- Regularly rotate AWS Academy credentials
- Monitor AWS costs and usage
