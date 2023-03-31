# Define the AWS provider and region
provider "aws" {
  region  = "ap-southeast-2"
  profile = "integral"
}

# Declare the input variables
variable "simple_ad_name" {
  type    = string
  default = "provident.local"
}

variable "simple_ad_password" {
  type    = string
  default = "@32$p2dqdxXBWY"
}



# Create a VPC with 3 public and 3 private subnets
module "vpc" {
  source                           = "terraform-aws-modules/vpc/aws"
  name                             = var.vpc_name
  cidr                             = var.vpc_cidr
  azs                              = var.vpc_azs
  private_subnets                  = var.vpc_private_subnets
  public_subnets                   = var.vpc_public_subnets
  map_public_ip_on_launch          = true
  enable_nat_gateway               = false
  single_nat_gateway               = false
  default_vpc_enable_dns_hostnames = true
  enable_dns_hostnames             = true
  enable_dns_support               = true
  tags = {
    Client      = "Provident"
    Terraform   = "true"
    Environment = "dev"
    Job         = "890"
    Milestone   = "81"
  }
}

# Create an AWS Simple AD directory that is available in all subnets
resource "aws_directory_service_directory" "provident_simple_ad" {
  name     = "provident.local"
  password = "X5959xfveS!8*fUY*NrF2Vcv^RxnM@GHq$"
  type     = "SimpleAD"
  size     = "Small"
  # edition  = "Standard"
  vpc_settings {
    vpc_id = module.vpc.vpc_id
    subnet_ids = [
      element(module.vpc.public_subnets, 0),
      element(module.vpc.public_subnets, 1),
    ]
  }
  tags = {
    Client      = "Provident"
    Terraform   = "true"
    Environment = "dev"
    Job         = "890"
    Milestone   = "81"
  }
}

# Set up DHCP options for the VPC to use the Simple AD DNS resolver
resource "aws_vpc_dhcp_options" "dns_resolver_provident" {
  domain_name_servers = [element(flatten([aws_directory_service_directory.provident_simple_ad.dns_ip_addresses]), 0)]
  domain_name         = "provident.local"
  tags = {
    Terraform   = "true"
    Environment = "dev"
    Client      = "Provident"
  }
}


# Associate the DHCP options with the VPC
resource "aws_vpc_dhcp_options_association" "dns_resolver_provident" {
  vpc_id          = module.vpc.vpc_id
  dhcp_options_id = aws_vpc_dhcp_options.dns_resolver_provident.id
}

# Add a key pair to the EC2 instances
resource "aws_key_pair" "my_key_pair" {
  key_name   = "my_key_pair"
  public_key = file("~/.ssh/id_rsa.pub")
}
