### General ###
output "config" {
  value = {
    bucket         = aws_s3_bucket.s3_bucket.bucket
    region         = data.aws_region.current.name
    role_arn       = aws_iam_role.iam_role.arn
    dynamodb_table = aws_dynamodb_table.dynamodb_table.name
  }
}
output account_id {
  value = data.aws_caller_identity.current.account_id
}

### VPC ###
output vpc_id {
  value       = module.vpc.vpc_id
}
output vpc_private_subnets_id {
  value       = module.vpc.private_subnets
}
output vpc_public_subnets_id {
  value       = module.vpc.public_subnets
}
output vpc_private_subnets_cidr_blocks {
  value       = module.vpc.private_subnets_cidr_blocks
}
output vpc_public_subnets_cidr_blocks {
  value       = module.vpc.public_subnets_cidr_blocks
}