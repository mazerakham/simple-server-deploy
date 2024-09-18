# Simple Server Deploy

This project demonstrates a simple Hello World API using Flask, designed for deployment on an AWS EC2 instance.

## Setup

1. Ensure you have Python 3.x installed.
2. Clone this repository.
3. Create a virtual environment:
   ```
   python3 -m venv venv
   ```
4. Activate the virtual environment:
   - On macOS and Linux:
     ```
     source venv/bin/activate
     ```
   - On Windows:
     ```
     venv\Scripts\activate
     ```
5. Install the required packages:
   ```
   pip install -r requirements.txt
   ```

## Running the Application Locally

To run the application locally:

```
python app.py
```

The API will be available at `http://localhost:5000`.

## Deployment to AWS EC2

1. Launch an EC2 instance on AWS:
   - Choose an Ubuntu Server AMI
   - Configure security group to allow inbound traffic on port 22 (SSH) and 5000 (Flask app)

2. Connect to your EC2 instance via SSH:
   ```
   ssh -i your-key-pair.pem ubuntu@your-ec2-public-dns
   ```

3. Clone this repository on the EC2 instance:
   ```
   git clone https://your-repository-url.git
   cd simple-server-deploy
   ```

4. Make the deployment script executable:
   ```
   chmod +x deploy.sh
   ```

5. Run the deployment script:
   ```
   ./deploy.sh
   ```

6. The API should now be running on your EC2 instance. You can access it at:
   ```
   http://your-ec2-public-dns:5000
   ```

Note: Replace 'your-key-pair.pem', 'your-ec2-public-dns', and 'your-repository-url' with your actual EC2 key pair file, EC2 instance public DNS, and GitHub repository URL respectively.