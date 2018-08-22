resource "aws_security_group" "alb-sg" {
  description = "controls access to elb"
  vpc_id      = "${module.vpc.vpc_id}"
  name        = "${var.name_prefix}-alb-sg"

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["${var.source_cidr_block_inbound}"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "${var.name_prefix}-alb-sg"
    Environment = "${var.environment}"
    Terraform   = "${var.terraform}"
    Owner       = "${var.owner}"
  }
}
module "alb" {
  source          = "git::https://github.com/shridharMe/terraform-modules.git//modules/alb"
  name_prefix     = "${var.name_prefix}-alb"
  internal        = "${var.internal}"
  security_groups = ["${aws_security_group.alb-sg.id}"]
  subnets         = ["${module.vpc.public_subnets}"]
  environment     = "${var.environment}"
  terraform       = "${var.terraform}"
  owner           = "${var.owner}"
  route53zoneid   = "${var.route53zoneid}"
  route53type     = "${var.route53type}"
  route53ttl      = "${var.route53ttl}"
}


module "listener" {
  source                   = "git::https://github.com/shridharMe/terraform-modules.git//modules/alb/listener/http"
  alb_arn                  = "${module.alb.arn}"
  default_target_group_arn = "${module.target_group_task.arn}"
}

module "listener-rule" {
  source           = "git::https://github.com/shridharMe/terraform-modules.git//modules/alb/listener-rule/path"
  listener_arn     = "${module.listener.arn}"
  priority         = "${var.priority}"
  path_pattern     = "${var.path_pattern}"
  target_group_arn = "${module.target_group_task.arn}"
}

module "target_group_task" {
  source            = "git::https://github.com/shridharMe/terraform-modules.git//modules/alb/target-group"
  name              = "${var.name_prefix}-alb-target-group"
  vpc_id            = "${module.vpc.vpc_id}"
  health_check_path = "${var.alb-health_check_path}"
  target_type       = "${var.alb_target_type}"
  port              = "8080"
}

resource "aws_lb_target_group_attachment" "ec2alb" {
  target_group_arn = "${module.target_group_task.arn}"
  target_id        = "${module.ec2.ec2_instance_id}"
  port             = 8080
}