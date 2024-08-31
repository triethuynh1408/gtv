# resource "aws_kms_key" "eks" {
#   description             = "EKS Secret Encryption Key"
#   deletion_window_in_days = 7
#   enable_key_rotation     = true

#   tags = local.tags
# }

# data "aws_ami" "eks_default" {
#   most_recent = true
#   owners      = ["amazon"]

#   filter {
#     name   = "name"
#     values = ["amazon-eks-node-${local.cluster_version}-v*"]
#   }
# }

# provider "kubernetes" {
#   host                   = module.eks.cluster_endpoint
#   cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

#   exec {
#     api_version = "client.authentication.k8s.io/v1beta1"
#     command     = "aws"
#     # This requires the awscli to be installed locally where Terraform is executed
#     args = ["eks", "get-token", "--cluster-name", module.eks.cluster_id]
#   }
# }

# module "eks" {
#   source  = "terraform-aws-modules/eks/aws"
#   version = "~> 18.0"

#   cluster_name                    = local.name
#   cluster_version                 = local.cluster_version
#   cluster_endpoint_private_access = true
#   cluster_endpoint_public_access  = false

#   create_cloudwatch_log_group = false

#   cluster_addons = {
#     coredns = {
#       most_recent = true
#     }
#     kube-proxy = {
#       most_recent = true
#     }
#     vpc-cni = {
#       most_recent = true
#     }
#   }

#   cluster_encryption_config = [{
#     provider_key_arn = aws_kms_key.eks.arn
#     resources        = ["secrets"]
#   }]

#   vpc_id     = module.vpc.vpc_id
#   subnet_ids = module.vpc.private_subnets

#   # Extend cluster security group rules
#   cluster_security_group_additional_rules = {
#     ops_private_access_egress = {
#       description = "Ops Private Egress"
#       protocol    = "-1"
#       from_port   = 0
#       to_port     = 0
#       type        = "egress"
#       cidr_blocks = ["10.1.0.0/16"]
#     }
#     ops_private_access_ingress = {
#       description = "Ops Private Ingress"
#       protocol    = "-1"
#       from_port   = 0
#       to_port     = 0
#       type        = "ingress"
#       cidr_blocks = ["10.1.0.0/16"]
#     }
#     egress_nodes_ephemeral_ports_tcp = {
#       description                = "To node 1025-65535"
#       protocol                   = "tcp"
#       from_port                  = 1025
#       to_port                    = 65535
#       type                       = "egress"
#       source_node_security_group = true
#     }
#   }

#   manage_aws_auth_configmap = true

#   aws_auth_users = var.aws_auth_users

#   enable_irsa = true

#   openid_connect_audiences = ["sts.amazonaws.com"]

#   node_security_group_additional_rules = {
#     ingress_self_all = {
#       description = "Node to node all ports/protocols"
#       protocol    = "-1"
#       from_port   = 0
#       to_port     = 0
#       type        = "ingress"
#       self        = true
#     }
#     egress_all = { # by default, only https urls can be reached from inside the cluster
#       description      = "Node all egress"
#       protocol         = "-1"
#       from_port        = 0
#       to_port          = 0
#       type             = "egress"
#       cidr_blocks      = ["0.0.0.0/0"]
#       ipv6_cidr_blocks = ["::/0"]
#     }
#     # ingress_karpenter_webhook_tcp = {
#     #   description                   = "Control plane invoke Karpenter webhook"
#     #   protocol                      = "tcp"
#     #   from_port                     = 8443
#     #   to_port                       = 8443
#     #   type                          = "ingress"
#     #   source_cluster_security_group = true
#     # }
#     ingress_allow_access_from_control_plane = {
#       type                          = "ingress"
#       protocol                      = "tcp"
#       from_port                     = 9443
#       to_port                       = 9443
#       source_cluster_security_group = true
#       description                   = "Allow access from control plane to webhook port of AWS load balancer controller"
#     }
#     ingress_custom_metrics = {
#       type        = "ingress"
#       protocol    = "tcp"
#       from_port   = 6443
#       to_port     = 6443
#       cidr_blocks = ["0.0.0.0/0"]
#       description = "Allow access custom metrics"
#     }
#     ingress_metrics_server = {
#         type        = "ingress"
#         protocol    = "tcp"
#         from_port   = 4443
#         to_port     = 4443
#         cidr_blocks = ["0.0.0.0/0"]
#         description = "Allow access metrics server"
#     }
#   }

#   # Self Managed Node Group(s)
#   # self_managed_node_group_defaults = {
#   #   vpc_security_group_ids       = [aws_security_group.additional.id]
#   #   iam_role_additional_policies = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]
#   # }
#   # self_managed_node_groups = []

#   eks_managed_node_groups = {
#     statefulset = {
#       name    = "${var.env}-sts-nodes"
#       subnet_ids  = [module.vpc.private_subnets[3]]
#       min_size     = 1
#       max_size     = 10
#       desired_size = 3

#       iam_role_additional_policies = [
#         "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
#           # "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
#       ]

#       ami_id  = data.aws_ami.eks_default.image_id
#       enable_bootstrap_user_data = true
#       bootstrap_extra_args       = "--container-runtime containerd --kubelet-extra-args '--node-labels nodeType=non-disruption --node-labels node.kubernetes.io/lifecycle=ondemand --node-labels node_group=sts --image-gc-low-threshold=50 --image-gc-high-threshold=70 --kube-reserved memory=300Mi,ephemeral-storage=1Gi --system-reserved memory=300Mi,ephemeral-storage=1Gi --eviction-hard memory.available<1Gi,nodefs.available<10%'"

#       pre_bootstrap_user_data = <<-EOT
#       export CONTAINER_RUNTIME="containerd"
#       export USE_MAX_PODS=true
#       EOT

#       post_bootstrap_user_data = <<-EOT
#       echo "you are free little kubelet!"
#       EOT
#       instance_types = ["t3.medium"]
#       capacity_type  = "ON_DEMAND"
#       force_update_version = true

#       ebs_optimized           = true
#       disable_api_termination = false
#       enable_monitoring       = true

#       block_device_mappings = {
#         xvda = {
#           device_name = "/dev/xvda"
#           ebs = {
#             volume_size           = 30
#             volume_type           = "gp3"
#             iops                  = 3000
#             throughput            = 150
#             delete_on_termination = true
#             encrypted             = true
#           }
#         }
#       }

#       labels = {
#         "nodeType"  = "non-disruption"
#       }
#       taints = {
#         dedicated = {
#           key = "dedicated"
#           value = "statefulset"
#           effect = "NO_SCHEDULE"
#         }
#       }
#       tags = merge(local.tags,{
#         "nodeType"  = "non-disruption"
#       })
#     }

#     application = {
#         name    = "${var.env}-app-nodes"
#         subnet_ids  = [module.vpc.private_subnets[0],module.vpc.private_subnets[1],module.vpc.private_subnets[2]]
#         min_size     = 1
#         max_size     = 10
#         desired_size = 1

#         iam_role_additional_policies = [
#             "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
#             # "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
#         ]

#         ami_id  = data.aws_ami.eks_default.image_id
#         enable_bootstrap_user_data = true
#         bootstrap_extra_args       = "--container-runtime containerd --kubelet-extra-args '--node-labels nodeType=disruption --node-labels node.kubernetes.io/lifecycle=spot --node-labels node_group=app --image-gc-low-threshold=50 --image-gc-high-threshold=70 --kube-reserved memory=300Mi,ephemeral-storage=1Gi --system-reserved memory=300Mi,ephemeral-storage=1Gi --eviction-hard memory.available<1Gi,nodefs.available<10%'"

#         pre_bootstrap_user_data = <<-EOT
#         export CONTAINER_RUNTIME="containerd"
#         export USE_MAX_PODS=true
#         EOT

#         instance_types = ["t3.medium"]
#         capacity_type  = "SPOT"
#         force_update_version = true

#         ebs_optimized           = true
#         disable_api_termination = false
#         enable_monitoring       = true

#         block_device_mappings = {
#             xvda = {
#                 device_name = "/dev/xvda"
#                 ebs = {
#                     volume_size           = 30
#                     volume_type           = "gp3"
#                     iops                  = 3000
#                     throughput            = 150
#                     delete_on_termination = true
#                     encrypted             = true
#                 }
#             }
#         }

#         labels = {
#             "nodeType"  = "disruption"
#         }
#         tags = merge(local.tags,{
#             "nodeType"  = "disruption"
#         })
#     }
#   }
# }