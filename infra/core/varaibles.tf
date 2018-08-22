variable "alb_target_type" {
    default = "instance"
}
variable "health_check_path" {
     default ="/"
}
variable "path_pattern" {
    default ="/"
}
variable "priority" {}
variable "name_prefix" {
    defualt =""
}
variable "source_cidr_block_inbound" {
    default =["0.0.0.0/0"]
    type ="list"
}

variable "internal" {
    default=true
}
variable "hosted_zone_name" {
     default=""
}
variable "route53type" {
     default="CNAME"
}
variable "route53ttl" {
     default="300"
}

variable "environment" {
   
    default ="dev"
}
variable "terraform" {
     default ="true"
}
variable "owner" {
     default ="Shridhar Patil"
}

variable "cidr" {
    default="10.1.0.0/16"
}
variable "public_subnets_cidr" {
      default=["10.1.1.0/24", "10.1.2.0/24"]
      type ="list"
}
variable "private_subnets_cidr"   {
    default =["10.1.3.0/24", "10.1.4.0/24"]
    type ="list"
}
variable "azs" {
    default =["eu-west-1a", "eu-west-1b", "eu-west-1c"]
    type = "list"
}

variable "ami_id"   {
default ="ami-6e28b517"
}
variable "instance_type" {
    default ="t2.micro"
}
variable "key_name"   {
    default="devops-key"
}
variable "resource_type_tag" {
     default=""
}