# Define the AWS provider and region
provider "aws" {
  region = "us-east-1"
}

# Create a VPC with 3 public and 3 private subnets
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name            = "neil-devops-vpc"
  cidr            = "10.0.0.0/16"
  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
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

# Create an AWS Managed Microsoft AD directory that is available in all subnets
resource "aws_directory_service_directory" "my_directory" {
  description = "ASDF Managed Microsoft AD Directory"
  name        = "asdf.co.nz"
  password    = "X5959xfveS!8*fUY*NrF2Vcv^RxnM@GHq$" # Replace with a strong password
  edition     = "Standard"
  type        = "MicrosoftAD" # Set the type to MicrosoftAD
  enable_sso  = false
  vpc_settings {
    vpc_id = module.vpc.vpc_id
    subnet_ids = [
      module.vpc.public_subnets[0],
      module.vpc.public_subnets[1],
    ]
  }
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

resource "aws_security_group" "rdp_access" {
  name_prefix = "rdp-access"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 3389
    to_port     = 3389
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
    Name        = "RDP-Access"
    Environment = "dev"
  }
}

resource "aws_security_group" "winrm_access" {
  name_prefix = "winrm-access"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 5985
    to_port     = 5986
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "WinRM-Access"
    Environment = "dev"
  }
}


# Add a key pair to the EC2 instance
resource "aws_key_pair" "my_key_pair" {
  key_name   = "nrf@grunt"
  public_key = file("~/.ssh/id_rsa.pub")
}

# Create an EC2 instance
resource "aws_instance" "devops-instance" {
  ami                         = "ami-011d76c658e2f3885"
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
  ami                         = "ami-005f9685cb30f234b"
  instance_type               = "t3a.micro"
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [aws_security_group.ssh_access.id]
  key_name                    = aws_key_pair.my_key_pair.key_name
  associate_public_ip_address = true

  tags = {
    Name        = "Pervasive-Instance"
    Environment = "dev"
  }


  provisioner "local-exec" {
    command = "ansible-playbook -i '${aws_instance.pervasive-instance.public_ip},' playbook-pervasive.yml --private-key ~/.ssh/id_rsa --user ec2-user"
  }
}

resource "aws_instance" "windows-instance" {
  ami = "ami-006eb93c66a20b8fd" #

  instance_type               = "t3a.medium"
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [aws_security_group.rdp_access.id, aws_security_group.winrm_access.id]
  key_name                    = aws_key_pair.my_key_pair.key_name
  associate_public_ip_address = true

  tags = {
    Name        = "Windows-Instance"
    Environment = "dev"
  }
  provisioner "local-exec" {
    command = "ansible-playbook -i '${aws_instance.windows-instance.public_ip},' playbook-windows.yml"
    environment = {
      ANSIBLE_HOST_KEY_CHECKING = "False"
    }
  }
}

# DNS Route 53 settings
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

resource "aws_route53_record" "a_win_asdf_co_nz" {
  zone_id = "Z02645693VHQRFVDHHYY4"
  name    = "win.asdf.co.nz"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.windows-instance.public_ip]
}
