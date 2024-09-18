#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Load environment variables from .env file
if [ -f .env ]; then
    export $(cat .env | xargs)
else
    echo ".env file not found. Creating one now."
    touch .env
fi

# Check if KEY_NAME is set, if not prompt for it
if [ -z "$KEY_NAME" ]; then
    read -p "Enter your AWS key pair name: " KEY_NAME
    echo "KEY_NAME=$KEY_NAME" >> .env
    export KEY_NAME
fi

# Verify the key pair exists
if ! aws ec2 describe-key-pairs --key-names "$KEY_NAME" > /dev/null 2>&1; then
    echo "Error: Key pair '$KEY_NAME' does not exist in your AWS account."
    exit 1
fi

# AWS Region
REGION="us-east-1"

# AMI ID for Ubuntu 20.04 LTS (adjust if needed)
AMI_ID="ami-0261755bbcb8c4a84"

# Instance type
INSTANCE_TYPE="t2.micro"

# Security group name
SECURITY_GROUP_NAME="simple-server-sg"

# Create security group
echo "Creating security group..."
SECURITY_GROUP_ID=$(aws ec2 create-security-group --group-name $SECURITY_GROUP_NAME --description "Security group for simple server" --output text --query 'GroupId')

# Configure security group
echo "Configuring security group..."
aws ec2 authorize-security-group-ingress --group-id $SECURITY_GROUP_ID --protocol tcp --port 22 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $SECURITY_GROUP_ID --protocol tcp --port 5000 --cidr 0.0.0.0/0

# Launch EC2 instance
echo "Launching EC2 instance..."
INSTANCE_ID=$(aws ec2 run-instances --image-id $AMI_ID --count 1 --instance-type $INSTANCE_TYPE --key-name "$KEY_NAME" --security-group-ids $SECURITY_GROUP_ID --output text --query 'Instances[0].InstanceId')

echo "Waiting for instance to be running..."
aws ec2 wait instance-running --instance-ids $INSTANCE_ID

# Get public DNS name
PUBLIC_DNS=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --output text --query 'Reservations[0].Instances[0].PublicDnsName')

echo "Instance is running. Public DNS: $PUBLIC_DNS"

# User data script to set up the instance
USER_DATA=$(cat <<EOF
#!/bin/bash
apt-get update
apt-get install -y python3-venv python3-pip
git clone https://github.com/mazerakham/simple-server-deploy.git /home/ubuntu/simple-server-deploy
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
systemctl enable simple-server
systemctl start simple-server
EOF
)

# Apply user data script to the instance
echo "Applying user data script..."
aws ec2 modify-instance-attribute --instance-id $INSTANCE_ID --attribute userData --value "$USER_DATA"

echo "EC2 setup complete. You can access your server at: http://$PUBLIC_DNS:5000"
echo "Instance ID: $INSTANCE_ID"
echo "Security Group ID: $SECURITY_GROUP_ID"

# Output the values as GitHub secrets
echo "Add the following secrets to your GitHub repository:"
echo "EC2_HOST: $PUBLIC_DNS"
echo "EC2_INSTANCE_ID: $INSTANCE_ID"

# Update .env file with new information
echo "EC2_HOST=$PUBLIC_DNS" >> .env
echo "EC2_INSTANCE_ID=$INSTANCE_ID" >> .env

echo "Environment variables have been updated in .env file."