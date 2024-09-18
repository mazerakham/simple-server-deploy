# Simple Server Deploy

This project demonstrates a simple Hello World API using Flask, designed for automated deployment on an AWS EC2 instance with CI/CD using GitHub Actions.

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

The API will be available at `http://localhost:5000`.

## Running Tests

To run the unit tests:

```
python -m unittest discover
```

## Automated EC2 Setup and Deployment

This project includes a script to automatically set up an EC2 instance and deploy the application. Here's how to use it:

1. Ensure you have the AWS CLI installed and configured with your credentials.

2. Run the EC2 setup script:
   ```
   chmod +x setup_ec2.sh
   ./setup_ec2.sh
   ```

3. If this is your first time running the script, it will create a `.env` file and prompt you for your AWS key pair name. This information will be stored in the `.env` file for future use.

4. The script will create an EC2 instance, set up the necessary security group, and configure the instance to run your Flask application.

5. After the script completes, it will output important information, including the EC2 instance's public DNS and instance ID. This information will also be saved in the `.env` file.

6. Add the following secrets to your GitHub repository (Settings > Secrets):
   - `EC2_HOST`: The public DNS of your EC2 instance (found in `.env`)
   - `EC2_INSTANCE_ID`: The ID of your EC2 instance (found in `.env`)
   - `AWS_ACCESS_KEY_ID`: Your AWS access key ID
   - `AWS_SECRET_ACCESS_KEY`: Your AWS secret access key

## CI/CD with GitHub Actions

This project uses GitHub Actions for Continuous Integration and Continuous Deployment. The workflow does the following:

1. Runs tests on every push and pull request to the main branch.
2. If tests pass and the push is to the main branch, it deploys the application to the EC2 instance.

The deployment process is fully automated and doesn't require manual SSH access to the EC2 instance.

## Making Changes

To make changes to the application:

1. Modify the code as needed.
2. Commit and push your changes to the main branch of the GitHub repository.
3. The GitHub Actions workflow will automatically test and deploy your changes to the EC2 instance.

You can access your deployed API at `http://your-ec2-public-dns:5000`, where `your-ec2-public-dns` is the public DNS of your EC2 instance (available in the EC2_HOST secret and `.env` file).

## Environment Variables

The project uses a `.env` file to store environment-specific variables. This file is created and updated by the `setup_ec2.sh` script. It contains:

- `KEY_NAME`: Your AWS key pair name
- `EC2_HOST`: The public DNS of your EC2 instance
- `EC2_INSTANCE_ID`: The ID of your EC2 instance

Make sure to keep this file secure and do not commit it to version control.

## Security Note

Remember to manage your AWS credentials securely and never commit them to version control. The `.env` file is included in `.gitignore` to prevent accidental commits of sensitive information.