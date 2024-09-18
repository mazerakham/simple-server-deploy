# Simple Server Deploy

This project demonstrates a simple Hello World API using Flask, designed for automated deployment on an AWS EC2 instance with CI/CD using GitHub Actions. The server runs on port 5001.

## Local Setup

1. Ensure you have Python 3.x installed.
2. Clone this repository:
   ```
   git clone https://github.com/mazerakham/simple-server-deploy.git
   cd simple-server-deploy
   ```
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

The API will be available at `http://localhost:5001`.

## Running Tests

To run the unit tests:

```
python -m unittest discover
```

## EC2 Setup and Deployment

This project includes two scripts for EC2 setup and deployment:

1. `setup_ec2.sh`: Sets up a new EC2 instance
2. `deploy_to_ec2.sh`: Deploys the application to an existing EC2 instance

### Setting Up a New EC2 Instance

1. Ensure you have the AWS CLI installed and configured with your credentials.

2. Run the EC2 setup script:
   ```
   chmod +x setup_ec2.sh
   ./setup_ec2.sh
   ```

3. The script will:
   - Create a `.env` file if it doesn't exist
   - Prompt you for your AWS key pair name if it's not already in the `.env` file
   - Create an EC2 instance and set up the necessary security group (opening ports 22 and 5001)
   - Save the EC2 instance's public DNS and instance ID to the `.env` file

### Deploying to an Existing EC2 Instance

1. Make sure you have run `setup_ec2.sh` at least once to create the `.env` file with the necessary EC2 information.

2. Run the deployment script:
   ```
   chmod +x deploy_to_ec2.sh
   ./deploy_to_ec2.sh
   ```

3. The script will:
   - Use the EC2 instance information from the `.env` file
   - Update the instance with the latest code from the repository
   - Install dependencies and set up the Flask application as a system service

## CI/CD with GitHub Actions

This project uses GitHub Actions for Continuous Integration and Continuous Deployment. The workflow does the following:

1. Runs tests on every push and pull request to the main branch.
2. If tests pass and the push is to the main branch, it deploys the application to the EC2 instance using the `deploy_to_ec2.sh` script.

To set up CI/CD:

1. In your GitHub repository, go to Settings > Secrets and add the following secrets:
   - `EC2_HOST`: The public DNS of your EC2 instance (from `.env`)
   - `EC2_INSTANCE_ID`: The ID of your EC2 instance (from `.env`)
   - `AWS_ACCESS_KEY_ID`: Your AWS access key ID
   - `AWS_SECRET_ACCESS_KEY`: Your AWS secret access key

2. Push your code to the main branch of your GitHub repository.

3. The GitHub Actions workflow will automatically run tests and deploy your application to the EC2 instance.

## Making Changes

To make changes to your application:

1. Modify the code as needed.
2. Commit and push your changes to the main branch of the GitHub repository.
3. The GitHub Actions workflow will automatically test and deploy your changes to the EC2 instance.

You can access your deployed API at `http://your-ec2-public-dns:5001`, where `your-ec2-public-dns` is the public DNS of your EC2 instance (available in the EC2_HOST secret and `.env` file).

## Environment Variables

The project uses a `.env` file to store environment-specific variables. This file is created and updated by the `setup_ec2.sh` script. It contains:

- `KEY_NAME`: Your AWS key pair name
- `EC2_HOST`: The public DNS of your EC2 instance
- `EC2_INSTANCE_ID`: The ID of your EC2 instance

Make sure to keep this file secure and do not commit it to version control.

## Security Note

Remember to manage your AWS credentials securely and never commit them to version control. The `.env` file is included in `.gitignore` to prevent accidental commits of sensitive information.