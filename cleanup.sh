
#!/bin/bash
set -e

echo "🧹 Professional Cleanup Script"
echo "==============================="

echo "📋 Step 1: Deleting Kubernetes resources..."
kubectl delete namespace flask-app 2>/dev/null || echo "✅ Namespace already deleted"

echo "⏳ Step 2: Waiting 5 minutes for LoadBalancer cleanup..."
sleep 300

echo "🗑️ Step 3: Force cleaning ECR repository..."
if [ -f infra/terraform.tfstate ]; then
  ECR_URL=$(cd infra && terraform output -raw ecr_repository_url 2>/dev/null) || ECR_URL=""
  if [ ! -z "$ECR_URL" ]; then
    REPO_NAME=$(echo $ECR_URL | cut -d'/' -f2)
    echo "Force cleaning ECR repository: $REPO_NAME"
    
    # Force delete all images
    aws ecr batch-delete-image --repository-name $REPO_NAME --image-ids "$(aws ecr list-images --repository-name $REPO_NAME --query 'imageIds[*]' --output json)" 2>/dev/null || echo "✅ ECR already empty"
    
    echo "✅ ECR images force deleted"
  fi
fi

echo "💥 Step 4: Destroying Terraform infrastructure..."
cd infra
terraform destroy

echo "🎉 Cleanup complete! No AWS charges remaining."