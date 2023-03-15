
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
#Create an EC2 instance for the Windows workload
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
}

