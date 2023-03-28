source "amazon-ebs" "centos7" {
  ami_name      = "my-ami {{timestamp}}"
  instance_type = "t2.micro"
  region        = "ap-southeast-2"
  source_ami    = "ami-0cf5f53cea16d8cbf"
  ssh_username  = "centos"
  ssh_pty       = true
}

build {
  sources = [
    "source.amazon-ebs.centos7"
  ]

  provisioner "ansible-local" {
    playbook_file = "magicxpa_install.yml"
    extra_arguments = [
      "--extra-vars",
      "ansible_ssh_private_key_file=my-keypair.pem"
    ]
  }

  post-processor "shell-local" {
    inline = [
      "echo 'AMI created, launching instance'",
      "aws ec2 run-instances --image-id ${build.sources[0].artifact_id} --count 1 --instance-type t2.micro --key-name my-keypair --security-group-ids sg-123456 --subnet-id subnet-123456 --user-data 'echo hello, world' > instance.json",
      "instance_id=`cat instance.json | jq -r '.Instances[0].InstanceId'`",
      "echo 'Instance launched, waiting for status ok'",
      "aws ec2 wait instance-status-ok --instance-ids $instance_id",
      "ip_address=`aws ec2 describe-instances --instance-ids $instance_id | jq -r '.Reservations[0].Instances[0].PublicIpAddress'`",
      "echo 'Instance ready, ssh to $ip_address'",
      "ssh -i my-keypair.pem centos@$ip_address 'echo hello, instance'"
    ]
  }
}
