# Define the AWS provider and region
provider "aws" {
  region = "us-east-2"
}


# Create a VPC with 3 public and 3 private subnets

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "neil-devops-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-2a", "us-east-2b", "us-east-2c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]


  # Allow auto-assign public IP on launce
  map_public_ip_on_launch = true
  # Create an Internet Gateway for this VPC
  enable_nat_gateway = true


  tags = {
    Terraform    = "true"
    Environment  = "dev"
  }
}

# Create a security group to allow SSH access to the EC2 instance

resource "aws_security_group" "ssh_access" {
  name_prefix = "ssh-access"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "SSH-Access"
    Environment = "dev"
  }
}

# Create a security group to allow internet egress the EC2 instance
resource "aws_security_group_rule" "egress_internet" {
  security_group_id = aws_security_group.ssh_access.id

  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

# Add a key pair to the EC2 instance

resource "aws_key_pair" "my_key_pair" {
  key_name   = "nrf@grunt"
  public_key = "${file("~/.ssh/id_rsa.pub")}"
}

# Create an EC2 instance

resource "aws_instance" "devops-instance" {
  ami           = "ami-00eeedc4036573771"
  instance_type = "t2.micro"
  subnet_id     = module.vpc.public_subnets[0]
  security_groups = [aws_security_group.ssh_access.id]
  key_name      = aws_key_pair.my_key_pair.key_name


  ebs_block_device {
    device_name = "/dev/xvda"
    volume_size = 8
  }


  tags = {
    Name        = "DevOps-Instance"
    Environment = "dev"
  }
}


