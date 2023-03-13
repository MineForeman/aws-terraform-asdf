variable "vpc_name" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "vpc_azs" {
  type = list(string)
}

variable "vpc_private_subnets" {
  type = list(string)
}

variable "vpc_public_subnets" {
  type = list(string)
}

variable "managed_ad_name" {
  type = string
}

variable "managed_ad_password" {
  type = string
}

variable "instance_ami_devops" {
  type = string
}

variable "instance_type_devops" {
  type = string
}

variable "instance_ami_pervasive" {
  type = string
}

variable "instance_type_pervasive" {
  type = string
}

variable "instance_ami_windows" {
  type = string
}

variable "instance_type_windows" {
  type = string
}

variable "route53_zone_id" {
  type = string
}

variable "route53_domain_name" {
  type = string
}
