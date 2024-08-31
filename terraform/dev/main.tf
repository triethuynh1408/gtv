provider "aws" {
  region = var.region
}

data "aws_region" "current" {}

resource "aws_resourcegroups_group" "resourcegroups_group" {
  name = "${var.project}-s3-backend"

  resource_query {
    query = <<-JSON
      {
        "ResourceTypeFilters": [
          "AWS::AllSupported"
        ],
        "TagFilters": [
          {
            "Key": "project",
            "Values": ["${var.project}"]
          }
        ]
      }
    JSON
  }
}

terraform {
  backend "s3" {
    bucket         = "gtv-terraform-s3-backend"
    key            = "dev"
    region         = "ap-southeast-1"
    encrypt        = true
    role_arn       = "arn:aws:iam::463470949045:role/Gtv-TerraformS3BackendRole"
    dynamodb_table = "gtv-terraform-s3-backend"
  }
}