### Security group for VPN Server ###
resource "aws_security_group" "vpn_access_server" {
  name        = "${var.project}-${var.env}-vpn-server"
  description = "Security group for VPN access server"
  vpc_id      = module.vpc.vpc_id

  tags = merge(local.tags, {
    Name = "${var.project}-${var.env}-vpn-server"
  })

  ingress {
    protocol  = "tcp"
    from_port = 22
    to_port   = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol  = "tcp"
    from_port = 943
    to_port   = 943
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol  = "tcp"
    from_port = 443
    to_port   = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol  = "udp"
    from_port = 1194
    to_port   = 1194
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

### EKS Cluster ###
# resource "aws_security_group" "additional" {
#   name_prefix = "${local.name}-additional"
#   vpc_id      = module.vpc.vpc_id

#   ingress {
#     from_port = 22
#     to_port   = 22
#     protocol  = "tcp"
#     cidr_blocks = ["10.1.0.0/16"]
#   }
#   tags = local.tags
# }