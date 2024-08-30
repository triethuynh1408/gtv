# Generate SSH private key and public key
resource "tls_private_key" "dev_keypair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "dev_keypair" {
  key_name   = "${local.name}-keypair"
  public_key = tls_private_key.dev_keypair.public_key_openssh
  
  # This command will generate private key PEM file and store localy for the first time run
  provisioner "local-exec" {
    command = <<-EOT
        echo '${tls_private_key.dev_keypair.private_key_pem}' > dev-keypair.pem
        chmod 400 dev-keypair.pem
    EOT
  }
}

# Store Public Key to SSM Parameter Store
resource "aws_ssm_parameter" "secret" {
  name        = "/dev/secret/keypair/publickey"
  description = "The public key of dev-keypair on dev environment"
  type        = "SecureString"
  value       = tls_private_key.dev_keypair.public_key_openssh

  tags = local.tags
}

data "aws_ssm_parameter" "dev_public_keypair" {
  name = "/dev/secret/keypair/publickey"
}