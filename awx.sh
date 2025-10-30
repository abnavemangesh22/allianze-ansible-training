#!/bin/bash
# AWX Installation Script on CentOS Stream 9 using Docker Compose
# Tested on CentOS Stream 9

set -e

echo "============================================"
echo "🚀 Starting AWX Installation on CentOS 9"
echo "============================================"

# Step 1: System update
echo "📦 Updating system..."
dnf update -y

# Step 2: Install dependencies
echo "🔧 Installing dependencies..."
dnf install -y epel-release git ansible make curl dnf-plugins-core

# Step 3: Install Docker CE
echo "🐳 Installing Docker..."
dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
dnf install -y docker-ce docker-ce-cli containerd.io
systemctl enable --now docker

# Step 4: Install Docker Compose
echo "🔧 Installing Docker Compose..."
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Step 5: Verify Docker setup
docker --version
docker-compose --version

# Step 6: Clone AWX repo
echo "📥 Cloning AWX repository..."
cd /opt
if [ ! -d "awx" ]; then
    git clone https://github.com/ansible/awx.git
fi
cd awx

# Checkout stable version (for Docker support)
git fetch --all --tags
git checkout 17.1.0

# Step 7: Configure AWX installer
cd installer

# Create inventory file
echo "⚙️ Configuring AWX inventory file..."
cat <<EOF > inventory
localhost ansible_connection=local

awx_task_hostname=awx
awx_web_hostname=awxweb

postgres_data_dir=/var/lib/awx/pgdocker
host_port=80

admin_user=admin
admin_password=Admin@123

project_data_dir=/var/lib/awx
EOF

# Step 8: Run Ansible playbook to install AWX
echo "🏗️ Running AWX installation playbook..."
ansible-playbook -i inventory install.yml

# Step 9: Final checks
echo "✅ Checking running containers..."
docker ps

echo "============================================"
echo "🎉 AWX Installation Completed Successfully!"
echo "============================================"
echo "🌐 Access the AWX Web UI at: http://$(hostname -I | awk '{print $1}')"
echo "👤 Username: admin"
echo "🔑 Password: Admin@123"
echo "============================================"

