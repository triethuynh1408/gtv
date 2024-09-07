# resource "aws_instance" "vpn_server" {
#   ami                         = "ami-0c20b8b385217763f" # Ubuntu AMI in ap-southeast-1
#   instance_type               = "t3.medium"
#   vpc_security_group_ids      = ["${aws_security_group.vpn_access_server.id}"]
#   associate_public_ip_address = true
#   subnet_id                   = module.vpc.public_subnets[0]
#   key_name                    = aws_key_pair.dev_keypair.key_name
#   iam_instance_profile        = aws_iam_instance_profile.openvpn-iam-profile.name

#   root_block_device {
#     delete_on_termination = true
#     volume_size = 50
#     volume_type = "gp3"
#   }

#   user_data = <<-EOF
#     #!/bin/bash
#     set -ex

#     apt-get update
#     curl -O https://raw.githubusercontent.com/angristan/openvpn-install/master/openvpn-install.sh
#     chmod +x openvpn-install.sh
#     APPROVE_INSTALL=y ENDPOINT=$(curl -4 ifconfig.co) APPROVE_IP=y IPV6_SUPPORT=n PORT_CHOICE=1 PROTOCOL_CHOICE=1 DNS=1 COMPRESSION_ENABLED=n  CUSTOMIZE_ENC=n CLIENT=dev-ovpn PASS=1 ./openvpn-install.sh 
#   EOF

#   depends_on = [aws_security_group.vpn_access_server]

#   tags = merge(local.tags,{
#     Name = "${var.project}-${var.env}-vpn-server"
#   })
# }

# resource "aws_eip" "vpn_server" {
#   instance = "${aws_instance.vpn_server.id}"
#   vpc = true
# }
