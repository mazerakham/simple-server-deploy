#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Load environment variables from .env file
if [ -f .env ]; then
    export $(cat .env | xargs)
else
    echo "Error: .env file not found. Please run setup_ec2.sh first."
    exit 1
fi

# Check if EC2_INSTANCE_ID is set
if [ -z "$EC2_INSTANCE_ID" ]; then
    echo "Error: EC2_INSTANCE_ID is not set in .env file. Please run setup_ec2.sh first."
    exit 1
fi

# Check if EC2_HOST is set
if [ -z "$EC2_HOST" ]; then
    echo "Error: EC2_HOST is not set in .env file. Please run setup_ec2.sh first."
    exit 1
fi

echo "Deploying to EC2 instance $EC2_INSTANCE_ID..."

# User data script to set up the instance
USER_DATA=$(cat <<EOF
#!/bin/bash
apt-get update
apt-get install -y python3-venv python3-pip
git clone https://github.com/mazerakham/simple-server-deploy.git /home/ubuntu/simple-server-deploy || (cd /home/ubuntu/simple-server-deploy && git pull)
chown -R ubuntu:ubuntu /home/ubuntu/simple-server-deploy
cd /home/ubuntu/simple-server-deploy
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
cat > /etc/systemd/system/simple-server.service <<EOL
[Unit]
Description=Simple Server Flask App
After=network.target

[Service]
User=ubuntu
WorkingDirectory=/home/ubuntu/simple-server-deploy
ExecStart=/home/ubuntu/simple-server-deploy/venv/bin/python app.py
Restart=always

[Install]
WantedBy=multi-user.target
EOL
systemctl daemon-reload
systemctl enable simple-server
systemctl restart simple-server
EOF
)

# Apply user data script to the instance
echo "Applying user data script..."
aws ec2 modify-instance-attribute --instance-id $EC2_INSTANCE_ID --attribute userData --value "$USER_DATA"

# Reboot the instance to apply changes
echo "Rebooting the instance..."
aws ec2 reboot-instances --instance-ids $EC2_INSTANCE_ID

echo "Waiting for instance to be running..."
aws ec2 wait instance-running --instance-ids $EC2_INSTANCE_ID

echo "Deployment complete. You can access your server at: http://$EC2_HOST:5001"