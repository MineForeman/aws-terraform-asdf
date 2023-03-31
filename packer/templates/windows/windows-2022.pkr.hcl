variable "aws_region" {
  type = string
}

variable "ansible_user" {
  type = string
}

variable "ansible_password" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "winrm_username" {
  type = string
}

variable "winrm_password" {
  type = string
}

variable "name_prefix" {
  type = string
}

locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

source "amazon-ebs" "firstrun-windows" {
  ami_name      = "${var.name_prefix}-packer-windows-2022-${local.timestamp}"
  communicator  = "winrm"
  instance_type = var.instance_type
  region        = var.aws_region
  source_ami_filter {
    filters = {
      name                = "Windows_Server-2022-English-Full-Base*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["amazon"]
  }
  user_data_file = "./templates/windows/bootstrap_win.txt"
  winrm_password = var.winrm_password
  winrm_username = var.winrm_username
  vpc_id         = "vpc-ae1dd2c7"
  subnet_id      = "subnet-a71dd2ce"

  tags = {
    Name = "${var.name_prefix}-Packer Windows 2022 AMI"
  }
}

build {
  name    = "learn-packer"
  sources = ["source.amazon-ebs.firstrun-windows"]

  provisioner "powershell" {
    inline = [
      "# Define the username and password for the new user",
      "$username = \"${var.ansible_user}\"",
      "$password = ConvertTo-SecureString \"${var.ansible_password}\" -AsPlainText -Force",
      "",
      "# Create the new user account",
      "New-LocalUser -Name $username -Password $password -FullName \"Ansible User\" -Description \"Local user for Ansible automation\" -AccountNeverExpires",
      "",
      "# Add the user to the local administrators group",
      "Add-LocalGroupMember -Group \"Administrators\" -Member $username"
    ]
  }
  provisioner "powershell" {
    environment_vars = ["VAR1=A$Dollar", "VAR2=A`Backtick", "VAR3=A'SingleQuote", "VAR4=A\"DoubleQuote"]
    script           = "./templates/windows/setup_ansible_user.ps1"
  }
  provisioner "powershell" {
    environment_vars = ["VAR1=A$Dollar", "VAR2=A`Backtick", "VAR3=A'SingleQuote", "VAR4=A\"DoubleQuote"]
    script           = "./templates/windows/setup_winrm.ps1"
  }
}
