name_prefix = "app"
alb_target_type = "instance"
alb_health_check_path = "/"
path_pattern = "/"
priority = "100"

source_cidr_block_inbound = ["0.0.0.0/0"]

internal = "false"
route53zoneid = ""
route53type = "CNAME"
route53ttl = "300"

environment = "dev"
terraform = "true"
owner = "Shridhar Patil"

cidr = "10.1.0.0/16"
public_subnets_cidr = ["10.1.1.0/24", "10.1.2.0/24"]
private_subnets_cidr = ["10.1.3.0/24", "10.1.4.0/24"]
azs = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]

ami_id = "ami-6e28b517" 
instance_type = "t2.micro"
key_name = "devops-key" 
resource_type_tag = "EC2 private instance"