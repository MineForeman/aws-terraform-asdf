variable "aws_region" {
  type = string
}

variable "ansible_user" {
  type        = string
  description = "Ansible user account"
  sensitive   = true
}

variable "ansible_password" {
  type        = string
  description = "Ansible user account password"
  sensitive   = true
}
