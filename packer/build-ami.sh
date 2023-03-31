#!/bin/bash

# Exit on any error
set -e

# Set the AWS profile
export AWS_PROFILE="integral"

# Set the AWS region
export AWS_REGION="ap-southeast-2"

# Set the Ansible user and password
export ANSIBLE_USER="ansible"
export ANSIBLE_PASSWORD="P@ssw0rd"

# Build Amazon Linux 2 AMI
# packer build -var "aws_region=$AWS_REGION" templates/amazon-linux-2.pkr.hcl

# Build RHEL 9 AMI
# packer build -var "aws_region=$AWS_REGION" templates/rhel9.pkr.hcl

# Build Ubuntu AMI
# packer build -var "aws_region=$AWS_REGION" templates/ubuntu.pkr.hcl

# Build Windows Server 2022 AMI
packer build \
  -var "aws_region=ap-southeast-2" \
  -var "ansible_user=ansible" \
  -var "ansible_password=P@ssw0rd" \
  -var "instance_type=t2.micro" \
  -var "winrm_username=Administrator" \
  -var "winrm_password=SuperS3cr3t!!!!" \
  -var "name_prefix=my_ami_prefix" \
  templates/windows/windows-2022.pkr.hcl

#packer build \
#  -var "aws_region=$AWS_REGION" \
#  -var "ansible_user=$ANSIBLE_USER" \
#  -var "ansible_password=$ANSIBLE_PASSWORD" \
#  ./templates/windows/windows-2022.pkr.hcl

# Build CentOS 7 AMI
# packer build -var "aws_region=$AWS_REGION" templates/centos7.pkr.hcl
