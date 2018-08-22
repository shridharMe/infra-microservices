module "vpc" {
 source             = "git::https://github.com/shridharMe/terraform-modules.git//modules/vpc?ref=master"
    name            = "${var.environment}-${var.name_prefix}-vpc"
    cidr            = "${var.cidr}"
    public_subnets  = "${var.public_subnets_cidr}"
    private_subnets = "${var.private_subnets_cidr}"
    azs             = "${var.azs}"
    owner           = "${var.owner}"
    environment     = "${var.environment}"
    terraform       = "${var.terraform}"
}

output "vpc_id" {
  value = "${module.vpc.vpc_id}"
}

output "cidr" {
  value = "${module.vpc.cidr}"
}

output "private_subnets" {
  value = ["${module.vpc.private_subnets}"]
}

output "private_subnets_cidr" {
  value = "${module.vpc.private_subnets_cidr}"
}


output "public_subnets" {
  value = ["${module.vpc.public_subnets}"]
}

output "public_subnets_cidr" {
  value = "${module.vpc.public_subnets_cidr}"
}


output "private_route_tables" {
  value = ["${module.vpc.private_route_tables}"]
}

output "public_route_tables" {
  value = ["${module.vpc.public_route_tables}"]
}

output "internet_gateway" {
  value = "${module.vpc.internet_gateway}"
}