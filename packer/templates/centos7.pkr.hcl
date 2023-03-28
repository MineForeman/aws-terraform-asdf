variable "aws_region" {
  type = string
}

source "amazon-ebs" "centos_7" {
  region = var.aws_region
  # Define the source AMI filter for CentOS 7
  source_ami_filter {
    filters = {
      virtualization-type = "hvm"
      name                = "CentOS 7.* x86_64 *"
      root-device-type    = "ebs"
    }
    owners      = ["679593333241"] # CentOS AWS Marketplace account ID
    most_recent = true
  }
  instance_type = "t2.micro"
  ssh_username  = "centos"
  ami_name      = "packer-centos-7-{{timestamp}}"
}

build {
  sources = ["source.amazon-ebs.centos_7"]
}
