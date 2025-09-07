DevSecOps Pipeline Project
Welcome to my DevSecOps Pipeline Project! This project demonstrates a comprehensive implementation of DevSecOps principles through a practical Python web application with a complete CI/CD pipeline that integrates security at every stage.
Project Overview
This project showcases how to implement DevSecOps practices by:

Building a secure Python web application
Setting up automated security testing
Creating a robust CI/CD pipeline with GitHub Actions
Deploying to AWS using Terraform with modular infrastructure
Implementing monitoring and security controls

Key Components

Python Web Application: A secure web application built with modern Python practices
Docker Containerization: Consistent deployment environments
AWS Infrastructure: Cloud-based deployment using modular Terraform architecture
Kubernetes Orchestration: Container management and scaling
GitHub Actions Workflows: Automated CI/CD pipeline with security gates
Security Testing: Integrated security scanning and testing

Getting Started

Clone the Repository

git clone <repository-url>
cd finalproj

Set Up Local Development Environment

python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt

Run the Application Locally

python -m app.main

Run Tests

python -m pytest tests/
Docker Support
Build and run the application using Docker:
docker build -t python-devsecops .
docker run -p 8000:8000 python-devsecops
AWS Deployment
Configure AWS CLI
aws configure
Enter your AWS credentials when prompted:
AWS Access Key ID: [Your Access Key]
AWS Secret Access Key: [Your Secret Key]
Default region name: us-west-2
Default output format: json
Deploy with Terraform
cd infra
terraform init
terraform plan
terraform apply -auto-approve
Verify Kubernetes Deployment
kubectl get pods -n default
CI/CD Pipeline with GitHub Actions
The project includes a complete GitHub Actions workflow that automates the entire deployment process.
GitHub Actions Setup

Configure Repository Secrets
Navigate to your repository → Settings → Secrets and variables → Actions, then add:
AWS_ACCESS_KEY_ID: [Your AWS Access Key]
AWS_SECRET_ACCESS_KEY: [Your AWS Secret Key]
AWS_REGION: us-west-2
ECR_REPOSITORY: [Your ECR repository name]

Workflow Configuration
The workflow is defined in .github/workflows/devsecops-pipeline.yml and triggers on:

Push to main branch
Pull requests to main branch
Manual dispatch



Pipeline Stages
The GitHub Actions workflow defines a complete pipeline with the following jobs:

Security Scan: Run dependency vulnerability scanning and SAST
Build and Test:

Build Docker image
Run unit tests with security checks
Perform container security scanning


Deploy Infrastructure:

Authenticate with AWS
Run Terraform with modular configuration
Deploy infrastructure using reusable modules


Deploy Application:

Push Docker image to Amazon ECR
Deploy to Kubernetes cluster


Post-Deployment Tests:

Verify deployment health
Run integration tests
Perform security validation


Cleanup (optional): Destroy resources when needed

Terraform Infrastructure Architecture
The project uses a modular Terraform approach for better organization and reusability:
cd infra
terraform init
terraform workspace select production  # or development
terraform plan -var-file="environments/production.tfvars"
terraform apply -var-file="environments/production.tfvars"
Infrastructure Modules

VPC Module: Network infrastructure with subnets, gateways, and security groups
EKS Module: Kubernetes cluster with worker nodes and IAM roles
ECR Module: Container registry for Docker images
Security Module: WAF, security groups, and compliance configurations
Monitoring Module: CloudWatch, logging, and alerting setup

Workflow Features

Parallel job execution for faster builds
Conditional deployment based on branch and environment
Artifact storage for build outputs
Comprehensive logging and monitoring
Failure notifications and rollback capabilities
Multi-environment support (dev, staging, production)

Security Features

Dependency scanning for vulnerabilities
SAST (Static Application Security Testing)
Container security scanning
Infrastructure as Code security validation with Terraform modules
Input validation and sanitization
Secrets management with GitHub Secrets
Compliance checks and security gates
Modular security policies per environment

Development Guidelines

Follow Python PEP 8 style guide
Write unit tests for new features
Perform security testing before submitting PRs
Keep dependencies updated
Document code changes
Use feature branches and pull requests
Follow Terraform module best practices

Project Structure
finalproj/
├── .github/
│   └── workflows/          # GitHub Actions workflow files
├── app/                    # Python web application
├── tests/                  # Test suite
├── infra/                  # Terraform infrastructure
│   ├── modules/            # Reusable Terraform modules
│   ├── main.tf             # Main Terraform configuration
│   ├── variables.tf        # Input variables
│   ├── outputs.tf          # Output values
├── kubernetes/             # K8s deployment manifests
├── Dockerfile              # Container definition
├── requirements.txt        # Python dependencies
└── README.md               # This file


GitHub Actions Workflow Example
The main workflow file (.github/workflows/devsecops-pipeline.yml) includes:

Automated testing on every commit
Security scanning integration
Multi-environment deployment support with Terraform workspaces
Infrastructure validation using modular approach
Rollback capabilities
Notification systems for pipeline status

Infrastructure Management
Environment Management
bash# Initialize and select workspace
terraform workspace new production
terraform workspace select production

# Deploy to specific environment
terraform apply -var-file="environments/production.tfvars"
Module Usage
Each infrastructure component is organized as a reusable module, making it easy to deploy consistent environments and maintain infrastructure as code best practices.
Future Enhancements

Implement advanced monitoring with Prometheus and Grafana
Add automated vulnerability management
Integrate compliance as code
Expand test coverage with GitHub Actions matrix builds
Add blue/green deployment strategy
Implement GitHub Environments for deployment approvals
Create additional Terraform modules for advanced AWS services
Add infrastructure testing with Terratest
