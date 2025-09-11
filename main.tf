#Configure the AWS provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region  = "eu-west-2"
  shared_credentials_files = ["~/.aws/credentials"]
  #profile = "default"
}

#Configure the VPC and Public Subnets
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"

  name = "${var.prefix}-f5-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["eu-west-2a"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.3.0/24"]

  enable_nat_gateway = true

  tags = {
    Terraform = true
    Environment = "${var.prefix}-vpc-teraform"
  }
}

#Configure the security Group for management and application access
resource "aws_security_group" "f5" {
  name   = "${var.prefix}-f5"
  vpc_id = module.vpc.vpc_id

 ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.prefix}-SecurityGroup1"
  }
}

#Reference the template file that will be used to configure host c1-cp1
data "template_file" "user_data1" {
  template = file("${path.module}/userdata1.tmpl")

}

#Build the host c1-cp1 instance and install prerequisites & then k8s
resource "aws_instance" "c1-cp1" {
  ami = "ami-0379821d182aac933"
  instance_type = "t3a.small"
  subnet_id   = module.vpc.public_subnets[1]
  private_ip = "10.0.2.10"
  key_name   = var.ssh_key_name
  user_data = data.template_file.user_data1.rendered
  security_groups = [ aws_security_group.f5.id ]
    tags = {
    Name = "${var.prefix}-c1-cp1"
  }
}

# Elastic IP for c1-cp1
resource "aws_eip" "c1-cp1" {
  instance = aws_instance.c1-cp1.id
  domain   = "vpc"
  
  tags = {
    Name = "${var.prefix}-c1-cp1-eip"
  }
  
  depends_on = [aws_instance.c1-cp1]
}

# Output the public IP address for c1-cp1
output "public_ip_1" {
  description = "Public IP address of the instance"
  value       = aws_eip.c1-cp1.public_ip
}

#Reference the template file that will be used to configure host c1-node1
data "template_file" "user_data2" {
  template = file("${path.module}/userdata2.tmpl")

}

#Build the host c1-node1 instance and install prerequisites & then k8s
resource "aws_instance" "c1-node1" {
  ami = "ami-0379821d182aac933"
  instance_type = "t3a.small"
  subnet_id   = module.vpc.public_subnets[1]
  private_ip = "10.0.2.11"
  key_name   = var.ssh_key_name
  user_data = data.template_file.user_data2.rendered
  security_groups = [ aws_security_group.f5.id ]
    tags = {
    Name = "${var.prefix}-c1-node1"
  }
}

# Elastic IP for c1-node1
resource "aws_eip" "c1-node1" {
  instance = aws_instance.c1-node1.id
  domain   = "vpc"
  
  tags = {
    Name = "${var.prefix}-c1-node1-eip"
  }
  
  depends_on = [aws_instance.c1-node1]
}

# Output the public IP address for c1-node1
output "public_ip_2" {
  description = "Public IP address of the instance"
  value       = aws_eip.c1-node1.public_ip
}

#Reference the template file that will be used to configure host c1-node2
data "template_file" "user_data3" {
  template = file("${path.module}/userdata3.tmpl")

}

#Build the host c1-node2 instance and install prerequisites & then k8s
resource "aws_instance" "c1-node2" {
  ami = "ami-0379821d182aac933"
  instance_type = "t3a.small"
  subnet_id   = module.vpc.public_subnets[1]
  private_ip = "10.0.2.12"
  key_name   = var.ssh_key_name
  user_data = data.template_file.user_data3.rendered
  security_groups = [ aws_security_group.f5.id ]
    tags = {
    Name = "${var.prefix}-c1-node2"
  }
}

# Elastic IP for c1-node2
resource "aws_eip" "c1-node2" {
  instance = aws_instance.c1-node2.id
  domain   = "vpc"
  
  tags = {
    Name = "${var.prefix}-c1-node2-eip"
  }
  
  depends_on = [aws_instance.c1-node2]
}

# Output the public IP address for c1-node2
output "public_ip_3" {
  description = "Public IP address of the instance"
  value       = aws_eip.c1-node2.public_ip
}

#Reference the template file that will be used to configure host c1-node3
data "template_file" "user_data4" {
  template = file("${path.module}/userdata4.tmpl")

}

#Build the host c1-node3 instance and install prerequisites & then k8s
resource "aws_instance" "c1-node3" {
  ami = "ami-0379821d182aac933"
  instance_type = "t3a.small"
  subnet_id   = module.vpc.public_subnets[1]
  private_ip = "10.0.2.13"
  key_name   = var.ssh_key_name
  user_data = data.template_file.user_data4.rendered
  security_groups = [ aws_security_group.f5.id ]
    tags = {
    Name = "${var.prefix}-c1-node3"
  }
}

# Elastic IP for c1-node3
resource "aws_eip" "c1-node3" {
  instance = aws_instance.c1-node3.id
  domain   = "vpc"
  
  tags = {
    Name = "${var.prefix}-c1-node3-eip"
  }
  
  depends_on = [aws_instance.c1-node3]
}

# Output the public IP address for c1-node3
output "public_ip_4" {
  description = "Public IP address of the instance"
  value       = aws_eip.c1-node3.public_ip
}

#Build the BIG-IP

resource "aws_network_interface" "mgmt" {
  subnet_id       = module.vpc.public_subnets[0]  # Management subnet
  private_ips     = ["10.0.1.100"]
  security_groups = [ aws_security_group.f5.id ]    # Management security group

  tags = {
    Name = "BIG-IP-MGMT"
  }
}

resource "aws_network_interface" "prod" {
  subnet_id       = module.vpc.public_subnets[1]  # Production subnet
  private_ips     = ["10.0.2.100"]
  security_groups = [ aws_security_group.f5.id ]    # Production security group

  tags = {
    Name = "BIG-IP-PROD"
  }
}

resource "aws_instance" "bigip" {
  ami           = "ami-00920d9e85b5caa90"       # Replace with BIG-IP AMI
  instance_type = "m5.large"
  key_name      = "OB1_keypair"

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.mgmt.id
  }

  network_interface {
    device_index         = 1
    network_interface_id = aws_network_interface.prod.id
  }

 user_data = <<-EOF
    #cloud-config
    chpasswd:
      list: |
        root:theBIGip4321?
        admin:theBIGip4321?
      expire: False
  EOF

  tags = {
    Name = "OB1_BIG_IP"
  }
}

resource "aws_eip" "bigip_mgmt_eip" {
  domain = "vpc"

  tags = {
    Name = "BIG-IP-MGMT-EIP"
  }
}

resource "aws_eip_association" "mgmt_eip_assoc" {
  allocation_id        = aws_eip.bigip_mgmt_eip.id
  network_interface_id = aws_network_interface.mgmt.id
}
