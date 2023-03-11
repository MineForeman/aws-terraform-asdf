# Define the AWS provider and region
provider "aws" {
  region = "us-east-2"
}

# Create a VPC with 3 public and 3 private subnets
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name            = "neil-devops-vpc"
  cidr            = "10.0.0.0/16"
  azs             = ["us-east-2a", "us-east-2b", "us-east-2c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  # Allow auto-assign public IP on launch
  map_public_ip_on_launch          = true
  enable_nat_gateway               = false
  single_nat_gateway               = false
  default_vpc_enable_dns_hostnames = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
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

# Create a security group to allow internet egress from the EC2 instance
#resource "aws_security_group_rule" "egress_internet" {
#  security_group_id = aws_security_group.ssh_access.id

#  type        = "egress"
#  from_port   = 0
#  to_port     = 0
#  protocol    = "tcp"
#  cidr_blocks = ["0.0.0.0/0"]
#}

# Add a key pair to the EC2 instance
resource "aws_key_pair" "my_key_pair" {
  key_name   = "nrf@grunt"
  public_key = file("~/.ssh/id_rsa.pub")
}

# Create an EC2 instance
resource "aws_instance" "devops-instance" {
  ami                         = "ami-00eeedc4036573771"
  instance_type               = "t3a.micro"
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [aws_security_group.ssh_access.id]
  key_name                    = aws_key_pair.my_key_pair.key_name
  associate_public_ip_address = true

  tags = {
    Name        = "DevOps-Instance"
    Environment = "dev"
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i '${aws_instance.devops-instance.public_ip},' playbook.yml --private-key ~/.ssh/id_rsa --user ubuntu"
  }
}

resource "aws_instance" "pervasive-instance" {
  ami                         = "ami-02238ac43d6385ab3"
  instance_type               = "t3a.micro"
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [aws_security_group.ssh_access.id]
  key_name                    = aws_key_pair.my_key_pair.key_name
  associate_public_ip_address = true

  tags = {
    Name        = "Pervasive-Instance"
    Environment = "dev"
  }

  #provisioner "file" {
  #  source = "install/PSQL-13.31-026.000.x86_64.rpm"
  #  destination = "/tmp/PSQL-13.31-026.000.x86_64.rpm"

  #  connection {
  #    type     = "ssh"
  #    user     = "ubuntu"
  #    private_key = file("~/.ssh/id_rsa")
  #    host     = self.public_ip
  #  }
  #}

  provisioner "local-exec" {
    command = "ansible-playbook -i '${aws_instance.pervasive-instance.public_ip},' playbook-pervasive.yml --private-key ~/.ssh/id_rsa --user ec2-user"
  }
}

resource "aws_route53_record" "a_nrf_asdf_co_nz" {
  zone_id = "Z02645693VHQRFVDHHYY4"
  name    = "nrf.asdf.co.nz"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.devops-instance.public_ip]
}

resource "aws_route53_record" "a_psql_asdf_co_nz" {
  zone_id = "Z02645693VHQRFVDHHYY4"
  name    = "psql.asdf.co.nz"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.pervasive-instance.public_ip]
}
