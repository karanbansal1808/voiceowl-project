
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.eks_vpc.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = aws_subnet.eks_public_subnet[*].id
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = aws_subnet.eks_private_subnet[*].id
}

output "cluster_id" {
  description = "EKS Cluster ID"
  value       = aws_eks_cluster.eks_cluster.id
}

output "cluster_endpoint" {
  description = "EKS Cluster endpoint"
  value       = aws_eks_cluster.eks_cluster.endpoint
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = aws_security_group.eks_cluster_sg.id
}

output "node_security_group_id" {
  description = "Security group ID attached to the EKS nodes"
  value       = aws_security_group.eks_nodes_sg.id
}

output "eks_cluster_role_arn" {
  description = "IAM role ARN for EKS cluster"
  value       = aws_iam_role.eks_cluster_role.arn
}

output "eks_node_group_role_arn" {
  description = "IAM role ARN for EKS node group"
  value       = aws_iam_role.eks_node_group_role.arn
}
