
# Create a security group to allow SSH access to the DevOps and Pervasive instances
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

# Create a security group to allow RDP and WinRM access to the Windows instance
resource "aws_security_group" "windows_access" {
  name_prefix = "windows-access"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5985
    to_port     = 5986
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
    Name        = "Windows-Access"
    Environment = "dev"
  }
}
