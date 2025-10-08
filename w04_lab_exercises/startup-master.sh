#!/bin/bash
set -e  # Exit on any error

# Log all output
exec > >(tee /var/log/k8s-master-setup.log) 2>&1

echo "=== Starting Kubernetes Master Setup ==="
date

# Load necessary kernel modules for containerd
echo "=== Configuring kernel modules ==="
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# Configure kernel networking requirements for Kubernetes
echo "=== Configuring kernel networking ==="
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes.conf
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sudo sysctl --system

# Disable swap permanently
echo "=== Disabling swap ==="
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Update package information and install prerequisites
echo "=== Installing prerequisites ==="
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gpg containerd

# Configure containerd with systemd cgroup driver
echo "=== Configuring containerd ==="
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml
# Enable systemd cgroup driver (required for Kubernetes)
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd

# Add modern Kubernetes repository - CREATE DIRECTORY FIRST!
echo "=== Setting up Kubernetes repository ==="
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Update package information and install Kubernetes components
echo "=== Installing Kubernetes components ==="
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# Start and enable kubelet
sudo systemctl enable kubelet

# Wait a moment for services to stabilize
sleep 10

# Initialize the Kubernetes cluster
echo "=== Initializing Kubernetes cluster ==="
sudo kubeadm init --pod-network-cidr=192.168.0.0/16 --kubernetes-version=v1.28.0

# Configure kubeconfig for ubuntu user
echo "=== Setting up kubeconfig ==="
mkdir -p /home/ubuntu/.kube
sudo cp -i /etc/kubernetes/admin.conf /home/ubuntu/.kube/config
sudo chown ubuntu:ubuntu /home/ubuntu/.kube/config

# Install Calico network plugin
echo "=== Installing Calico network plugin ==="
sudo -u ubuntu kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml

# Wait for Calico to start
echo "=== Waiting for Calico to be ready ==="
sleep 30

# Note: Use 'kubeadm token create --print-join-command' to get join command for worker nodes
echo "=== Cluster initialization complete ==="

# Wait for cluster to be ready
echo "=== Waiting for cluster to be ready ==="
sudo -u ubuntu kubectl wait --for=condition=Ready nodes --all --timeout=300s || true

# Create completion marker
echo "=== Creating completion marker ==="
echo "$(date): Master setup completed successfully" > /home/ubuntu/master-ready.txt
echo "Master node is ready for worker nodes to join" >> /home/ubuntu/master-ready.txt

echo "=== Kubernetes Master Setup Complete ==="
echo "Cluster status:"
sudo -u ubuntu kubectl get nodes
echo "System pods status:"
sudo -u ubuntu kubectl get pods -n kube-system

date
echo "=== Setup finished ==="
