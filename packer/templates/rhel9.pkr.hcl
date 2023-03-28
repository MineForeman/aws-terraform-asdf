variable "aws_region" {
  type = string
}

source "amazon-ebs" "rhel_9" {
  region = var.aws_region
  # Define the source AMI filter for RHEL 9
  source_ami_filter {
    filters = {
      virtualization-type = "hvm"
      name                = "RHEL-9.0*-*-*-*-*"
      root-device-type    = "ebs"
      architecture        = "x86_64"
    }
    owners      = ["309956199498"]
    most_recent = true
  }
  instance_type = "t2.micro"
  ssh_username  = "ec2-user"
  ami_name      = "packer-rhel-9-{{timestamp}}"
}

build {
  sources = ["source.amazon-ebs.rhel_9"]
}
