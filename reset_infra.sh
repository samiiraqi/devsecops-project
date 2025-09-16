#!/usr/bin/env bash
set -euo pipefail

# --------------------------
# Configuration
# --------------------------
AWS_REGION="us-east-1"
ACCOUNT_ID="156041402173"
CLUSTER_NAME="devsecops"
TF_BACKEND_BUCKET="devsecops-156041402173-us-east-1"
TF_BACKEND_KEY="tfstate/devsecops-project.tfstate"
TF_LOCK_TABLE="terraform-locks"
INFRA_DIR="infra"
DELETE_ECR=true            # set false if you want to keep ECR
DELETE_K8S_NAMESPACES=true # set false to keep namespaces
K8S_NAMESPACES=("devsecops-project-staging" "devsecops-project-prod") # list namespaces to delete

# --------------------------
# Step 1: Destroy Terraform-managed resources
# --------------------------
echo "==> Destroying Terraform-managed resources..."
cd "$INFRA_DIR"
terraform init -upgrade
terraform destroy -auto-approve || echo "Terraform destroy finished (some resources may have been manually removed)"

# --------------------------
# Step 2: Clean local Terraform files
# --------------------------
echo "==> Cleaning local Terraform files..."
rm -rf .terraform
rm -f *.tfstate *.tfstate.backup tfplan *.plan .terraform.lock.hcl.backup README.test

# --------------------------
# Step 3: Delete remote state and lock table
# --------------------------
echo "==> Deleting remote Terraform state and lock table..."
aws s3 rm "s3://${TF_BACKEND_BUCKET}/${TF_BACKEND_KEY}" || echo "Remote state not found or already deleted"
aws dynamodb delete-table --table-name "${TF_LOCK_TABLE}" || echo "Lock table not found or already deleted"

# --------------------------
# Step 4: Delete ECR repositories/images
# --------------------------
if [ "$DELETE_ECR" = true ]; then
    echo "==> Deleting all ECR repositories/images..."
    REPOS=$(aws ecr describe-repositories --query 'repositories[].repositoryName' --output text || echo "")
    if [ -n "$REPOS" ]; then
        for repo in $REPOS; do
            echo "Deleting repo: $repo"
            aws ecr delete-repository --repository-name "$repo" --force || echo "Failed to delete repo $repo"
        done
    else
        echo "No ECR repositories found."
    fi
fi

# --------------------------
# Step 5: Delete Kubernetes namespaces (if cluster exists)
# --------------------------
if [ "$DELETE_K8S_NAMESPACES" = true ]; then
    echo "==> Deleting Kubernetes namespaces..."
    if aws eks describe-cluster --name "$CLUSTER_NAME" --region "$AWS_REGION" >/dev/null 2>&1; then
        aws eks update-kubeconfig --name "$CLUSTER_NAME" --region "$AWS_REGION"
        for ns in "${K8S_NAMESPACES[@]}"; do
            kubectl delete namespace "$ns" --ignore-not-found=true || echo "Namespace $ns not found"
        done
    else
        echo "EKS cluster $CLUSTER_NAME does not exist. Skipping namespace deletion."
    fi
fi

# --------------------------
# Step 6: Done
# --------------------------
echo "==> All Terraform artifacts and cloud resources cleaned. Infra is now fresh."
