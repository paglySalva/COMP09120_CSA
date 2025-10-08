# SSH Key Setup for AWS Academy Students

This guide explains how to configure SSH access to your Kubernetes cluster instances.

## Option 1: Using AWS Academy Default Key Pair (Recommended)

AWS Academy provides a default key pair called "vockey" that you can use without any additional setup.

### Steps:

1. **Keep the default configuration in `terraform.tfvars`:**
   ```
   key_name           = "vockey"
   create_key_pair    = false
   public_key_content = ""
   ```

2. **Download the private key for SSH access:**
   - In your AWS Academy lab interface, click the "Download PEM" button under "SSH key"
   - Save the downloaded file (usually named `labsuser.pem`) to a secure location
   - Set proper permissions on the file:
     
     **For macOS/Linux users:**
     ```bash
     chmod 400 /path/to/your/labsuser.pem
     ```
     
     **For Windows users:**
     ```powershell
     # Method 1: Using PowerShell (Recommended)
     icacls "C:\path\to\your\labsuser.pem" /inheritance:r /grant:r "%USERNAME%":R
     
     # Method 2: Using File Properties GUI
     # Right-click the .pem file → Properties → Security tab → Advanced
     # Disable inheritance → Remove all permissions → Add only your user with Read permission
     ```
     
     **For Windows users with WSL (Windows Subsystem for Linux):**
     ```bash
     chmod 400 /mnt/c/path/to/your/labsuser.pem
     ```

3. **Connect to your instances using SSH:**
   
   **For macOS/Linux users:**
   ```bash
   ssh -i /path/to/your/labsuser.pem ubuntu@<instance-public-ip>
   ```
   
   **For Windows users with PowerShell/Command Prompt:**
   ```cmd
   ssh -i "C:\path\to\your\labsuser.pem" ubuntu@<instance-public-ip>
   ```
   
   **For Windows users with WSL:**
   ```bash
   ssh -i /mnt/c/path/to/your/labsuser.pem ubuntu@<instance-public-ip>
   ```
   
   **For Windows users with PuTTY:**
   - Convert .pem to .ppk format using PuTTYgen
   - Use the .ppk file in PuTTY connection settings

## Option 2: Create Your Own Key Pair (Advanced)

If you prefer to use your own SSH key pair, follow these steps:

### Steps:

1. **Generate a new SSH key pair** (if you don't have one):
   ```bash
   ssh-keygen -t rsa -b 2048 -f ~/.ssh/k8s_key
   ```

2. **Extract the public key content:**
   ```bash
   cat ~/.ssh/k8s_key.pub
   ```
   Copy the entire output (it should start with `ssh-rsa`).

3. **Update `terraform.tfvars`:**
   ```
   key_name           = "my-k8s-key"          # Choose a unique name
   create_key_pair    = true                  # Set to true to create new key pair
   public_key_content = "ssh-rsa AAAAB3Nza..." # Paste your public key content here
   ```

4. **Connect to your instances:**
   ```bash
   ssh -i ~/.ssh/k8s_key ubuntu@<instance-public-ip>
   ```

## Troubleshooting

### Common Issues:

1. **Permission denied (publickey) error:**
   - **For macOS/Linux:** Ensure your private key file has correct permissions: `chmod 400 your-key.pem`
   - **For Windows:** Use the icacls command or GUI method shown above to restrict permissions
   - Verify you're using the correct username (`ubuntu` for Ubuntu instances)
   - Check that the key pair name in `terraform.tfvars` matches what exists in AWS
   - **Windows users:** Try using double quotes around the file path: `ssh -i "C:\path\to\key.pem"`

2. **Key pair not found error:**
   - If using `create_key_pair = false`, make sure the key pair exists in your AWS account
   - For AWS Academy, the default key pair is usually named "vockey"

3. **Invalid key format error:**
   - When using `create_key_pair = true`, ensure the `public_key_content` is the full public key content
   - The public key should start with `ssh-rsa` and be on a single line

### Getting Your Instance IP Addresses:

After running `terraform apply`, the public IP addresses will be shown in the output. You can also get them with:

```bash
terraform output
```

Or check in the AWS Console under EC2 > Instances.

## Windows Users - Detailed Instructions

### Setting Permissions on Windows (Step-by-Step)

**Method 1: PowerShell Command (Recommended)**
1. Open PowerShell as Administrator
2. Navigate to your .pem file location:
   ```powershell
   cd "C:\Users\YourUsername\Downloads"
   ```
3. Run the permission command:
   ```powershell
   icacls "labsuser.pem" /inheritance:r /grant:r "%USERNAME%":R
   ```

**Method 2: File Properties GUI**
1. Right-click the `labsuser.pem` file
2. Select "Properties"
3. Go to the "Security" tab
4. Click "Advanced"
5. Click "Disable inheritance"
6. Choose "Remove all inherited permissions"
7. Click "Add" → "Select a principal"
8. Type your username and click "OK"
9. Check only "Read" permission
10. Click "OK" on all dialogs

**Method 3: Windows Subsystem for Linux (WSL)**
If you have WSL installed:
```bash
# Copy the file to WSL file system first (recommended)
cp /mnt/c/Users/YourUsername/Downloads/labsuser.pem ~/labsuser.pem
chmod 400 ~/labsuser.pem

# Then use it with SSH
ssh -i ~/labsuser.pem ubuntu@<instance-ip>
```

### SSH Connection Options for Windows

**Option 1: Built-in SSH Client (Windows 10+)**
```cmd
ssh -i "C:\Users\YourUsername\Downloads\labsuser.pem" ubuntu@<instance-ip>
```

**Option 2: PowerShell**
```powershell
ssh -i "C:\Users\YourUsername\Downloads\labsuser.pem" ubuntu@<instance-ip>
```

**Option 3: PuTTY (Alternative)**
1. Download PuTTY and PuTTYgen
2. Open PuTTYgen
3. Click "Load" and select your .pem file
4. Click "Save private key" to create a .ppk file
5. In PuTTY:
   - Host Name: `ubuntu@<instance-ip>`
   - Connection → SSH → Auth → Browse for your .ppk file

## Security Notes:

- Never share your private key files
- Always use proper file permissions on private key files:
  - **macOS/Linux:** `chmod 400`
  - **Windows:** Use icacls or GUI method above
- Consider restricting the `external_ip` variable in `terraform.tfvars` to your specific IP address instead of `0.0.0.0/0`
