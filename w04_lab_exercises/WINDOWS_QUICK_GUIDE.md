# Quick Guide for Windows Users

## TL;DR - Windows SSH Setup

### 1. Set Permissions on Your PEM File

**Open PowerShell as Administrator and run:**
```powershell
cd "C:\Users\YourUsername\Downloads"
icacls "labsuser.pem" /inheritance:r /grant:r "%USERNAME%":R
```

### 2. Connect to Your VMs

**Use this SSH command format:**
```cmd
ssh -i "C:\path\to\your\labsuser.pem" ubuntu@<instance-ip>
```

**Example:**
```cmd
ssh -i "C:\Users\YourName\Downloads\labsuser.pem" ubuntu@54.224.162.63
```

## Alternative Methods

### Using File Properties (GUI Method)
1. Right-click `labsuser.pem` → Properties
2. Security tab → Advanced
3. Disable inheritance → Remove all permissions
4. Add only your user with Read permission

### Using WSL (Windows Subsystem for Linux)
```bash
# Copy file to WSL first
cp /mnt/c/Users/YourUsername/Downloads/labsuser.pem ~/labsuser.pem
chmod 400 ~/labsuser.pem

# Then SSH normally
ssh -i ~/labsuser.pem ubuntu@<instance-ip>
```

### Using PuTTY
1. Download PuTTY and PuTTYgen
2. Convert .pem to .ppk using PuTTYgen
3. Use .ppk file in PuTTY connection settings

## Common Windows Issues

**"Permission denied (publickey)" error:**
- Make sure you're using double quotes around the file path
- Verify the permissions are set correctly
- Try copying the file to a simpler path like `C:\keys\labsuser.pem`

**"Bad permissions" error:**
- Run the icacls command again
- Make sure only your user has access to the file

**SSH command not found:**
- Windows 10/11 has SSH built-in
- If not available, install OpenSSH or use PuTTY

For complete details, see `SSH_KEY_SETUP.md`
