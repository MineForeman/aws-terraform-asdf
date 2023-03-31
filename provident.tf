resource "aws_instance" "provident-dev" {
  ami                         = var.instance_ami_windows
  instance_type               = var.instance_type_windows
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [aws_security_group.windows_access.id]
  key_name                    = aws_key_pair.my_key_pair.key_name
  associate_public_ip_address = true

  tags = {
    Name        = "Provident-Dev"
    Environment = "dev"
    Client      = "Provident"
    Job         = "890"
    Milestone   = "81"
  }

  depends_on = [
    aws_directory_service_directory.provident_simple_ad
  ]

  provisioner "local-exec" {
    command = "ansible-playbook -i '${aws_instance.provident-dev.public_ip},' ansible/win-zz*.yml || true"
    environment = {
      ANSIBLE_HOST_KEY_CHECKING = "False"
    }
  }
}

data "aws_subnet" "selected" {
  id = module.vpc.public_subnets[0]
}

resource "aws_volume_attachment" "provident-dev-d" {
  device_name = "/dev/xvdd"
  volume_id   = "vol-0c915d227e91f4f53" # Reference the existing volume ID directly
  instance_id = aws_instance.provident-dev.id
}

resource "aws_route53_record" "dns_a_provd" {
  zone_id = var.route53_zone_id
  name    = "provd.${var.route53_domain_name}"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.provident-dev.public_ip]

  depends_on = [aws_instance.provident-dev]
}


