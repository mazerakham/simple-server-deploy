#!/bin/bash

# Update the system
sudo apt-get update
sudo apt-get upgrade -y

# Install Python and pip
sudo apt-get install -y python3 python3-pip

# Install required Python packages
pip3 install -r requirements.txt

# Run the Flask app in the background
nohup python3 app.py > output.log 2>&1 &

echo "Deployment complete. API should be running on port 5000."