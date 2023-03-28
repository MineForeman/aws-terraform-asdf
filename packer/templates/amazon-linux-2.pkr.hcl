variable "aws_region" {
  type = string
}

source "amazon-ebs" "amazon_linux_2" {
  region = var.aws_region
  # Define the source AMI filter for Amazon Linux 2
  source_ami_filter {
    filters = {
      virtualization-type = "hvm"
      name                = "amzn2-ami-hvm-*-x86_64-gp2"
      root-device-type    = "ebs"
    }
    owners      = ["amazon"]
    most_recent = true
  }
  instance_type = "t2.micro"
  ssh_username  = "ec2-user"
  ami_name      = "packer-amazon-linux-2-{{timestamp}}"
}

build {
  sources = ["source.amazon-ebs.amazon_linux_2"]
}
