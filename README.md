# DevSecOps Pipeline Project

Welcome to our DevSecOps Pipeline Project!  
This project demonstrates a comprehensive implementation of DevSecOps principles through a practical Python web application with a complete CI/CD pipeline that integrates security at every stage.

---

## 📌 Project Overview

This project showcases how to implement DevSecOps practices by:

- Building a secure Python web application  
- Setting up automated security testing  
- Creating a robust CI/CD pipeline with GitHub Actions  
- Deploying to AWS using Terraform with modular infrastructure  
- Implementing monitoring and security controls

---

## 🔧 Key Components

- **Python Web Application:** A secure web application built with modern Python practices  
- **Docker Containerization:** Consistent deployment environments  
- **AWS Infrastructure:** Cloud-based deployment using modular Terraform architecture  
- **Kubernetes Orchestration:** Container management and scaling  
- **GitHub Actions Workflows:** Automated CI/CD pipeline with security gates  
- **Security Testing:** Integrated security scanning and testing  

---

## 🚀 Getting Started

### Clone the Repository

```bash
git clone <repository-url>
cd finalproj
Set Up Local Development Environment
bash
Copy code
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
Run the Application Locally
bash
Copy code
python -m app.main
Run Tests
bash
Copy code
python -m pytest tests/
🐳 Docker Support
Build and run the application using Docker:

bash
Copy code
docker build -t python-devsecops .
docker run -p 8000:8000 python-devsecops
☁️ AWS Deployment
Configure AWS CLI
bash
Copy code
aws configure
Provide your credentials:

AWS Access Key ID

AWS Secret Access Key

Region: us-west-2

Output format: json

Deploy with Terraform
bash
Copy code
cd infra
terraform init
terraform plan
terraform apply -auto-approve
☸️ Verify Kubernetes Deployment
bash
Copy code
kubectl get pods -n default
🔄 CI/CD Pipeline with GitHub Actions
The project includes a complete GitHub Actions workflow that automates the entire deployment process.

Configure Repository Secrets
Go to:
Settings → Secrets and variables → Actions → New repository secret

Add the following secrets:

AWS_ACCESS_KEY_ID

AWS_SECRET_ACCESS_KEY

AWS_REGION (e.g., us-west-2)

ECR_REPOSITORY (your ECR repo name)

Workflow Triggers
The workflow (.github/workflows/devsecops-pipeline.yml) runs on:

Push to main

Pull requests to main

Manual dispatch

🔁 Pipeline Stages
Security Scan

Dependency scanning

Static Application Security Testing (SAST)

Build and Test

Build Docker image

Unit tests + security checks

Container scanning

Deploy Infrastructure

AWS authentication

Modular Terraform deployment

Deploy Application

Push Docker image to ECR

Deploy to Kubernetes

Post-Deployment

Health checks

Integration + security tests

Cleanup (optional)

Destroy resources

🏗️ Terraform Infrastructure
bash
Copy code
cd infra
terraform init
terraform workspace select production  # or development
terraform plan -var-file="environments/production.tfvars"
terraform apply -var-file="environments/production.tfvars"
Infrastructure Modules
VPC Module: Subnets, gateways, security groups

EKS Module: Cluster, nodes, IAM roles

ECR Module: Container registry

Security Module: WAF, security groups

Monitoring Module: CloudWatch + logging

⚙️ Workflow Features
Parallel job execution

Conditional deployments

Artifact storage

Logging and monitoring

Notifications + rollback

Multi-env support (dev, staging, prod)

🔐 Security Features
Dependency scanning

Static code analysis (SAST)

Container scanning

IaC security validation (Terraform)

Input sanitization

Secrets management via GitHub

Compliance checks and policies

🧪 Development Guidelines
Follow PEP 8

Write unit tests for all features

Security test before PRs

Keep dependencies updated

Use PRs + feature branches

Document changes clearly

Follow Terraform best practices

📁 Project Structure
bash
Copy code
finalproj/
├── .github/
│   └── workflows/          # GitHub Actions workflows
├── app/                    # Python web app
├── tests/                  # Unit/integration tests
├── infra/                  # Terraform infrastructure
│   ├── modules/
│   │   ├── vpc/
│   │   ├── eks/
│   │   ├── ecr/
│   │   ├── storage
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── versions.tf
├── kubernetes/             # K8s manifests
├── Dockerfile              # Docker build file
├── requirements.txt        # Python deps
└── README.md               # This file

🧪 GitHub Actions Example
The file .github/workflows/full-deploy.yml includes:

Automated testing

Security scanning

Multi-env deployment (Terraform workspaces)

Rollback support

Notifications

📦 Infrastructure Management
Environment Setup
bash
Copy code
terraform workspace new production
terraform workspace select production
terraform apply -var-file="environments/production.tfvars"
🧱 Module Usage
Each component is modular and reusable, ensuring clean, scalable, and consistent deployments across environments.

🌱 Future Enhancements
Prometheus + Grafana monitoring

Automated vulnerability management

Compliance as code

GitHub Actions matrix builds

Blue/Green deployments

GitHub Environments for approvals

Advanced Terraform modules

Infra testing with Terratest

yaml
Copy code
