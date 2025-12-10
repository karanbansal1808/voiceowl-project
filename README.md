## Application Source

The Node.js application (`server.js` and `package.json`) is based on the publicly available [express-mongo-rest-starter](https://github.com/leob/express-mongo-rest-starter) repository.

## Project Structure

```
devsecops-project/
├── server.js                 # Node.js/Express application
├── package.json              # Node.js dependencies
├── Dockerfile                # Multi-stage Docker build
├── .dockerignore             # Docker ignore file
├── .gitignore                # Git ignore file
├── .github/
│   └── workflow/
│       └── ci-cd.yml         # CI/CD pipeline with security scanning
├── terraform/
│   ├── main.tf               # Main Terraform configuration
│   ├── variables.tf          # Terraform variables
│   └── outputs.tf            # Terraform outputs
|   └── terraform.tfvars      # Terraform inputs
├── k8s/
│   ├── namespace.yaml        # Kubernetes namespace
│   ├── mongodb-deployment.yaml  # MongoDB deployment
│   ├── app-deployment.yaml   # Application deployment
│   ├── network-policy.yaml   # Network policies
│   ├── pdb.yaml              # Pod Disruption Budget
│   ├── hpa.yaml              # Horizontal Pod Autoscaler
│   └── monitoring/
│       ├── prometheus-config.yaml      # Prometheus configuration
│       ├── prometheus-deployment.yaml  # Prometheus deployment
│       └── alert-rules.yaml            # Alert rules
└── README.md                 # This file
└── scan-results/             # Different scan results
```

## Setup Instructions

### 1. Local Development Setup

#### Install Dependencies
```bash
cd voiceowl-devsecops-project
npm install
```

#### Run Locally
```bash
# Set environment variables
export MONGODB_URI=mongodb://localhost:27017/devsecops
export PORT=3000

# Start MongoDB (using Docker)
docker run -d -p 27017:27017 --name mongodb mongo:7.0

# Start application
npm start
```

### 2. Docker Build and Scan

#### Build Docker Image
```bash
docker build -t devsecops-nodejs-app:latest .
```

#### Run Trivy Scan
```bash

# Scan image
trivy image devsecops-nodejs-app:latest --severity HIGH,CRITICAL --format table > trivy-results.txt

# Scan with SARIF output
trivy image devsecops-nodejs-app:latest --format sarif -o trivy-results.sarif
```

### 3. Terraform Validation

#### Initialize Terraform
```bash
cd terraform
terraform init
```

#### Validate Terraform Code
```bash
terraform validate
```

#### Format Terraform Code
```bash
terraform fmt -check
terraform fmt
```

#### Run Checkov Security Scan
```bash
# Scan Terraform code
checkov -d . --framework terraform -o json > checkov-results.json
checkov -d . --framework terraform
```

#### Run tfsec Security Scan (Alternative)
```bash

cd terraform
tfsec . > tfsec-results.txt
```

### 4. Kubernetes Deployment (Local)

#### Start Local Kubernetes Cluster

**Using minikube:**
```bash
minikube start
kubectl get nodes
```

**Using kind:**
```bash
kind create cluster --name devsecops
kubectl get nodes
```

#### Deploy Application

```bash
# Apply all Kubernetes manifests
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/mongodb-deployment.yaml
kubectl apply -f k8s/app-deployment.yaml
kubectl apply -f k8s/network-policy.yaml
kubectl apply -f k8s/pdb.yaml
kubectl apply -f k8s/hpa.yaml

# Verify deployments
kubectl get pods -n devsecops
kubectl get services -n devsecops
kubectl get ingress -n devsecops
```

#### Validate Kubernetes Manifests
```bash
# Dry-run validation
kubectl apply --dry-run=client -f k8s/

# Validate specific resources
kubectl apply --dry-run=client -f k8s/app-deployment.yaml
kubectl apply --dry-run=client -f k8s/network-policy.yaml
```

#### Check Pod Security Context
```bash
# Verify pods are running as non-root
kubectl get pod -n devsecops -o jsonpath='{.items[*].spec.securityContext.runAsUser}'

# Check pod details
kubectl describe pod -n devsecops -l app=devsecops-app
```

### 5. Monitoring Setup

#### Deploy Prometheus
```bash
kubectl apply -f k8s/monitoring/prometheus-config.yaml
kubectl apply -f k8s/monitoring/prometheus-deployment.yaml
kubectl apply -f k8s/monitoring/alert-rules.yaml

# Port forward to access Prometheus UI
kubectl port-forward -n monitoring svc/prometheus 9090:9090
```

Access Prometheus at: http://localhost:9090

### 6. CI/CD Pipeline

1. **Pipeline will automatically**:
   - Run Semgrep static analysis
   - Build Docker image
   - Run Trivy vulnerability scan
   - Push image to GitHub Container Registry (on main branch)

## Commands Reference

### Docker Commands
```bash
# Build image
docker build -t devsecops-nodejs-app:latest .

# Run container
docker run -p 3000:3000 devsecops-nodejs-app:latest

# Scan with Trivy
trivy image devsecops-nodejs-app:latest
```

### Terraform Commands
```bash
# Initialize
terraform init

# Validate
terraform validate

# Format
terraform fmt
```

### Kubernetes Commands
```bash
# Get pods
kubectl get pods -n devsecops

# Get services
kubectl get svc -n devsecops

# Describe pod
kubectl describe pod <pod-name> -n devsecops

# Validate manifests
kubectl apply --dry-run=client -f k8s/
```

### Security Scanning Commands
```bash
# Trivy scan
trivy image devsecops-nodejs-app:latest --severity HIGH,CRITICAL

# Semgrep scan
semgrep --config=auto .

# Checkov scan
checkov -d terraform/ --framework terraform

# tfsec scan
tfsec terraform/
```

## How Terraform Maps to Real AWS EKS

The Terraform code simulates a real AWS EKS deployment:

1. **VPC**: Creates isolated network environment (`aws_vpc`)
2. **Subnets**: Public subnets for load balancers, private subnets for nodes (`aws_subnet`)
3. **Internet Gateway**: Provides internet access for public subnets (`aws_internet_gateway`)
4. **NAT Gateways**: Allows private subnets to access internet (`aws_nat_gateway`)
5. **Route Tables**: Routes traffic between subnets (`aws_route_table`)
6. **IAM Roles**: 
   - EKS Cluster Role: Allows EKS service to manage cluster (`aws_iam_role.eks_cluster_role`)
   - Node Group Role: Allows nodes to join cluster (`aws_iam_role.eks_node_group_role`)
7. **Security Groups**: Controls network traffic (`aws_security_group`)
8. **EKS Cluster**: Managed Kubernetes cluster (`aws_eks_cluster`)
9. **Node Group**: EC2 instances running Kubernetes nodes (`aws_eks_node_group`)

