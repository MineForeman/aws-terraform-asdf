# Define the AWS provider and region
provider "aws" {
  region = "us-east-1"
}

# Create a VPC with 3 public and 3 private subnets
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name            = var.vpc_name
  cidr            = var.vpc_cidr
  azs             = var.vpc_azs
  private_subnets = var.vpc_private_subnets
  public_subnets  = var.vpc_public_subnets
  # Allow auto-assign public IP on launch
  map_public_ip_on_launch          = true
  enable_nat_gateway               = false
  single_nat_gateway               = false
  default_vpc_enable_dns_hostnames = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}


# Create an AWS Managed Microsoft AD directory that is available in all subnets
resource "aws_directory_service_directory" "my_directory" {
  description = "ASDF Managed Microsoft AD Directory"
  name        = var.managed_ad_name
  password    = var.managed_ad_password # Replace with a strong password
  edition     = "Standard"
  type        = "MicrosoftAD" # Set the type to MicrosoftAD
  enable_sso  = false
  vpc_settings {
    vpc_id = module.vpc.vpc_id
    subnet_ids = [
      module.vpc.public_subnets[0],
      module.vpc.public_subnets[1],
    ]
  }



  tags = {
    Terraform   = "true"
    Environment = "dev"
  }

}


resource "aws_vpc_dhcp_options" "dns_resolver" {

  domain_name_servers = aws_directory_service_directory.my_directory.dns_ip_addresses
  domain_name = "asdf.co.nz"

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}




resource "aws_vpc_dhcp_options_association" "dns_resolver" {

  vpc_id = module.vpc.vpc_id


  dhcp_options_id = aws_vpc_dhcp_options.dns_resolver.id

}


# Add a key pair to the EC2 instances
resource "aws_key_pair" "my_key_pair" {
  key_name   = "nrf@grunt"
  public_key = file("~/.ssh/id_rsa.pub")
}
