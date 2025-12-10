# Terraform variables file
# This file contains dummy values for local validation
# For production, use environment variables or AWS CLI configuration

aws_region = "us-east-1"
project_name = "devsecops"
environment = "production"

vpc_cidr = "10.0.0.0/16"
kubernetes_version = "1.28"

node_instance_types = ["t3.medium"]
node_desired_size = 2
node_min_size = 1
node_max_size = 4

# Dummy AWS credentials for local validation only
# These are not used when skip_credentials_validation = true
aws_access_key = "dummy-access-key"
aws_secret_key = "dummy-secret-key"

# Optional: SSH key for node access
# ssh_key_name = "my-ssh-key"

