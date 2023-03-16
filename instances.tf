
/*

#Create an EC2 instance for the DevOps workload
resource "aws_instance" "devops-instance" {

  ami                         = var.instance_ami_devops
  instance_type               = var.instance_type_devops
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [aws_security_group.ssh_access.id]
  key_name                    = aws_key_pair.my_key_pair.key_name
  associate_public_ip_address = true

  tags = {
    Name        = "DevOps-Instance"
    Environment = "dev"
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i '${aws_instance.devops-instance.public_ip},' ansible/playbook.yml --private-key ~/.ssh/id_rsa --user ubuntu"
  }
}

#Create an EC2 instance for the Pervasive workload
resource "aws_instance" "pervasive-instance" {
  ami                         = var.instance_ami_pervasive
  instance_type               = var.instance_type_pervasive
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [aws_security_group.ssh_access.id]
  key_name                    = aws_key_pair.my_key_pair.key_name
  associate_public_ip_address = true

  tags = {
    Name        = "Pervasive-Instance"
    Environment = "dev"
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i '${aws_instance.pervasive-instance.public_ip},' ansible/playbook-pervasive.yml --private-key ~/.ssh/id_rsa --user ec2-user"
  }
}

*/
resource "aws_instance" "windows-instance" {
  ami                         = var.instance_ami_windows
  instance_type               = var.instance_type_windows
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [aws_security_group.windows_access.id]
  key_name                    = aws_key_pair.my_key_pair.key_name
  associate_public_ip_address = true

  tags = {
    Name        = "Windows-Instance"
    Environment = "dev"
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i '${aws_instance.windows-instance.public_ip},' ansible/win-0*.yml"
    environment = {
      ANSIBLE_HOST_KEY_CHECKING = "False"
    }
  }

  depends_on = [aws_directory_service_directory.my_directory,aws_ebs_volume.d_drive]
}

resource "aws_ebs_volume" "d_drive" {
  availability_zone = data.aws_subnet.selected.availability_zone
  size              = 10 # Size in GiB for D drive
  type              = "gp3"

  tags = {
    Name        = "D-Drive"
    Environment = "dev"
  }
}

data "aws_subnet" "selected" {
  id = module.vpc.public_subnets[0]
}


resource "aws_volume_attachment" "d_drive_attachment" {
  device_name   = "/dev/xvdd"
  volume_id     = aws_ebs_volume.d_drive.id
  instance_id   = aws_instance.windows-instance.id
}
