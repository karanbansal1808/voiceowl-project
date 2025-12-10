# Terraform EKS Infrastructure

This Terraform configuration simulates an AWS EKS (Elastic Kubernetes Service) deployment. It can be validated locally without requiring an actual AWS account.

## How This Terraform Maps to Real AWS EKS

### Network Infrastructure

1. **VPC (`aws_vpc.eks_vpc`)**
   - Creates an isolated virtual network (10.0.0.0/16)
   - Enables DNS hostnames and support for DNS resolution
   - Maps to: AWS VPC service

2. **Subnets (`aws_subnet.eks_public_subnet` & `aws_subnet.eks_private_subnet`)**
   - **Public Subnets**: For load balancers and NAT gateways
     - Tagged with `kubernetes.io/role/elb=1` for EKS load balancer integration
   - **Private Subnets**: For EKS nodes and application pods
     - Tagged with `kubernetes.io/role/internal-elb=1` for internal load balancers
   - Maps to: AWS Subnets within VPC

3. **Internet Gateway (`aws_internet_gateway.eks_igw`)**
   - Provides internet access for public subnets
   - Maps to: AWS Internet Gateway

4. **NAT Gateways (`aws_nat_gateway.eks_nat_gateway`)**
   - Allows private subnets to access internet for pulling images, updates
   - Maps to: AWS NAT Gateway service

5. **Route Tables (`aws_route_table`)**
   - Public routes: Direct traffic to Internet Gateway
   - Private routes: Direct traffic through NAT Gateways
   - Maps to: AWS Route Tables

### Security

6. **Security Groups (`aws_security_group`)**
   - **EKS Cluster SG**: Controls traffic to EKS control plane (port 443)
   - **EKS Nodes SG**: Controls traffic to worker nodes
   - Maps to: AWS Security Groups (stateful firewalls)

### IAM Roles

7. **EKS Cluster Role (`aws_iam_role.eks_cluster_role`)**
   - Allows EKS service to create and manage the cluster
   - Attached policies: `AmazonEKSClusterPolicy`
   - Maps to: AWS IAM Role for EKS service

8. **EKS Node Group Role (`aws_iam_role.eks_node_group_role`)**
   - Allows EC2 instances (nodes) to join the EKS cluster
   - Attached policies:
     - `AmazonEKSWorkerNodePolicy`: Allows nodes to register with cluster
     - `AmazonEKS_CNI_Policy`: Allows VPC CNI plugin to manage networking
     - `AmazonEC2ContainerRegistryReadOnly`: Allows pulling container images
   - Maps to: AWS IAM Role for EC2 instances

### EKS Components

9. **EKS Cluster (`aws_eks_cluster.eks_cluster`)**
   - Creates managed Kubernetes control plane
   - Version: Kubernetes 1.28
   - Deployed in private subnets with endpoint access control
   - CloudWatch logging enabled for audit
   - Maps to: AWS EKS Cluster service

10. **EKS Node Group (`aws_eks_node_group.eks_node_group`)**
    - Creates EC2 instances running Kubernetes worker nodes
    - Instance types: t3.medium (configurable)
    - Auto-scaling: 1-4 nodes (configurable)
    - Deployed in private subnets only
    - Rolling update strategy
    - Maps to: AWS EKS Managed Node Groups

## Local Validation

This Terraform code can be validated locally without AWS credentials:

```bash
terraform init
terraform validate
terraform fmt -check
```

The provider is configured with `skip_credentials_validation = true` for local validation.

