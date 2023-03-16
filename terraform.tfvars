vpc_name                = "neil-devops-vpc"
vpc_cidr                = "10.0.0.0/16"
vpc_azs                 = ["us-east-1a", "us-east-1b", "us-east-1c"]
vpc_private_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
vpc_public_subnets      = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
managed_ad_name         = "asdf.co.nz"
managed_ad_password     = "X5959xfveS!8*fUY*NrF2Vcv^RxnM@GHq$"
instance_ami_devops     = "ami-011d76c658e2f3885"
instance_type_devops    = "t3a.micro"
instance_ami_pervasive  = "ami-005f9685cb30f234b"
instance_type_pervasive = "t3a.micro"
instance_ami_windows    = "ami-0b4a1588940e11f48"
instance_type_windows   = "t3a.medium"
route53_zone_id         = "Z02645693VHQRFVDHHYY4"
route53_domain_name     = "asdf.co.nz"
