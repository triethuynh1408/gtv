### General ###
output "config" {
  value = {
    bucket         = aws_s3_bucket.s3_bucket.bucket
    region         = data.aws_region.current.name
    role_arn       = aws_iam_role.iam_role.arn
    dynamodb_table = aws_dynamodb_table.dynamodb_table.name
  }
}
output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

### VPC ###
output "vpc_id" {
  value       = module.vpc.vpc_id
}
output "vpc_private_subnets_id" {
  value       = module.vpc.private_subnets
}
output "vpc_public_subnets_id" {
  value       = module.vpc.public_subnets
}
output "vpc_private_subnets_cidr_blocks" {
  value       = module.vpc.private_subnets_cidr_blocks
}
output "vpc_public_subnets_cidr_blocks" {
  value       = module.vpc.public_subnets_cidr_blocks
}

### EC2 Keypair ###
output "public_key" {
  description = "Public key"
  value       = tls_private_key.dev_keypair.public_key_openssh
  sensitive   = true
}
output "private_key" {
  description = "Private key"
  value       = tls_private_key.dev_keypair.private_key_pem
  sensitive   = true
}
output "ssm_parameter_publickey" {
  value = data.aws_ssm_parameter.dev_public_keypair.value
  sensitive   = true
}

### VPN ###
output "vpn_server_public_ip" {
  value = aws_eip.vpn_server.public_ip
}
output "vpn_server_private_ip" {
  value = aws_instance.vpn_server.private_ip
}

### EKS ###
# output "eks_arn" {
#   value = module.eks.cluster_arn
# }
