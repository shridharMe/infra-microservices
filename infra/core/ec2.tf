 
data "template_file" "userdata" {
  template                = "${file("${path.module}/files/userdata.tpl")}"
  CUSTOM_NETWORK_NAME     = "local_network"
}

data "aws_iam_policy_document" "instance-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com","ecs.amazonaws.com"]
    }
  }
}
resource "aws_iam_role" "instance-assume-role" {	    
	name               = "${var.name_prefix}-role"
  path               = "/"
	assume_role_policy = "${data.aws_iam_policy_document.instance-assume-role-policy.json}"
}

resource "aws_iam_role_policy" "iecr-power-user-policy" {
  role        = "${aws_iam_role.instance-assume-role.id}"
  name        = "${var.name_prefix}-ecr-policy"
  policy      = "${file("${path.module}/files/ecr-power-user-policy.json")}"
}

resource "aws_iam_instance_profile" "instance_profile" {	  
    name        = "${var.name_prefix}-iam-profile"	    
    role        = "${aws_iam_role.instance-assume-role.name}"	
}
resource "aws_security_group" "instance-app-sg" {
  name          = "${var.name_prefix}-app-sg"
  description   = "${var.name_prefix}-app-sg"
  vpc_id        = "${module.vpc.vpc_id}"
  ingress {
           from_port      = 8080
           to_port        = 8080
           protocol       = "tcp"
           security_groups = ["${var.cidr}"]
          }
  ingress {
      from_port           = 22
      to_port             = 22
      protocol            = "tcp"
      cidr_blocks         = ["${var.cidr}"]
    }
  ingress {
    from_port             = 80
    to_port               = 80
    protocol              = "tcp"
    cidr_blocks           = ["${var.cidr}"]
  }
  egress {
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
         }
   tags {
    Name = "${var.name_prefix}-app-sg"
  }
}

data "aws_route53_zone" "route53" {
  name = "${var.hosted_zone_name}."
}

module "ec2" {
    source                = "git::https://github.com/shridharMe/terraform-modules.git//modules/ec2?ref=master"
    key_name              ="${var.key_name}"
    name                  ="${var.name_prefix}"
    user_data             ="${data.template_file.userdata.rendered}"
    environment           ="${var.environment}"
    resource_type_tag     ="${var.resource_type_tag}"
    subnet_ids            =["${module.vpc.private_subnets}"]
    vpc_id                ="${module.vpc.vpc_id}"
    security_groups       =["${aws_security_group.instance-app-sg.id}"]
    route53_zone_id       = "${data.aws_route53_zone.route53.zone_id}"
    iam_instance_profile  ="${aws_iam_instance_profile.instance_profile.name}"
    ami_id                ="${var.ami_id}"
    type                  ="${var.instance_type}"
}