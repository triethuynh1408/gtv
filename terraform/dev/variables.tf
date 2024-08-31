locals {
  name            = replace(basename(path.cwd), "_", "-")
  region          = var.region
  cluster_version = "1.30"
  account_id      = var.account_id

  tags = merge(var.tags, {
    Env = local.name
    Project = var.project
  })
}

variable "region" {
  type = string
  default = "ap-southeast-1"
}

variable "project" {
  description = "The project name to use for unique resource naming"
  default     = "gtv-terraform"
  type        = string
}

variable "principal_arns" {
  description = "A list of principal arns allowed to assume the IAM role"
  default     = null
  type        = list(string)
}

variable "env" {
  type        = string
  default     = "dev"
}

variable "account_id" {
  type        = string
  default     = "463470949045"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "aws_auth_users" {
  description = "Developers with access to the dev K8S cluster and the container registries"
  default = [
    {
      userarn  = "arn:aws:iam::463470949045:user/candidate.triet"
      username = "candidate.triet"
      groups   = ["system:masters"]
    }
  ]
}