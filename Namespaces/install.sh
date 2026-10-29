#!/bin/bash
set -e          # Exit immediately if a command exits with a non-zero status
set -o pipefail # Return value of a pipeline is the status of the last command to exit with a non-zero status

echo "🚀 Starting Kubernetes Namespace and Deployment Lab..."

# -----------------------------------------------------------------------------
# Optional: Cluster Setup
# -----------------------------------------------------------------------------
# Uncomment the line below if you need to run your local cluster installation script first
# ./kind-cluster/kind-install.sh

# -----------------------------------------------------------------------------
# Step 1 & 6: Create the Namespace (Using both CLI and YAML methods for practice)
# -----------------------------------------------------------------------------
echo "📦 Step 1: Creating 'dev' namespace via CLI..."
if kubectl get namespace dev >/dev/null 2>&1; then
    echo "⚠️ Namespace 'dev' already exists. Skipping creation."
else
    kubectl create namespace dev
fi

echo "📄 Step 6: Applying namespace using a YAML definition..."

kubectl apply -f namespace.yaml

# -----------------------------------------------------------------------------
# Step 5: Set a default namespace for kubectl context
# -----------------------------------------------------------------------------
echo "⚙️ Setting 'dev' as the default namespace for the current context..."
kubectl config set-context --current --namespace=dev

echo "🔍 Verifying the updated context configuration..."
kubectl config view --minify

# -----------------------------------------------------------------------------
# Step 2: Create the Deployment
# -----------------------------------------------------------------------------
echo "🚀 Step 2: Deploying Nginx inside the 'dev' namespace..."
# Since the context is set to 'dev', explicit '-n dev' is omitted to test the context
kubectl create deployment nginx --image=nginx

# -----------------------------------------------------------------------------
# Step 3 & 4: Verify resources and compare namespaces
# -----------------------------------------------------------------------------
echo "⏳ Waiting for Nginx deployment to roll out..."
kubectl rollout status deployment/nginx --timeout=60s

echo "📋 Step 3 & 4: Verifying resources in the default context ('dev')..."
echo "--- Pods in 'dev' ---"
kubectl get pods
echo "--- Deployments in 'dev' ---"
kubectl get deployments

echo "📋 Comparing with the cluster's 'default' namespace..."
echo "--- Pods in 'default' namespace ---"
kubectl get pods -n default

# -----------------------------------------------------------------------------
# Cleanup / Reset Context
# -----------------------------------------------------------------------------
echo "🔄 Resetting kubectl context back to the 'default' namespace..."
kubectl config set-context --current --namespace=default

echo "🎉 Script execution finished successfully!"
echo "💡 To clean up the generated practice resources manually, run:"
echo "   kubectl delete namespace dev && rm namespace.yaml"
