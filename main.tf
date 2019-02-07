provider "aws" {
  region                        = "${var.aws_region}"
}
/* SSM PARAMETER TO STORE JENKINS INITIAL PASSWORD */

resource "aws_ssm_parameter" "jenkins_initial_password" {
  name                          = "jenkins_initial_password"
  type                          = "SecureString"
  value                         = "Please check the initial password for Jenkins at AWS Console --> EC2 --> Parameter Store --> jenkins_initial_password after EC2 status check initialization phase"
}

/* USER DATA TO RUN DURING EC2 INITIALIZATION */

data "template_file" "userdata" {
  template                      = "${file("${path.module}/aws_jenkins_userdata.sh")}"
}

/* IAM ROLE AND POLICIES TO ALLOW EC2 TO ACCESS SSM */

data "template_file" "EC2toSSM_role" {
  template                      = "${file("var.ec2tossm_role_file")}"
}
data "template_file" "EC2toSSM_policy" {
  template                      = "${file("${var.ec2tossm_policy_file")}"
}

resource "aws_iam_role" "EC2toSSM_role" {
  name                          = "${var.app_name}-${var.environment}-role"
  assume_role_policy            = "${data.template_file.EC2toSSM_role.rendered}"
}

resource "aws_iam_policy" "EC2toSSM_policy" {
  name                          = "${var.app_name}-${var.environment}-policy"
  description                   = "${var.app_name}-${var.environment} policy to allow EC2 to access SSM"
  policy                        = "${data.template_file.EC2toSSM_policy.rendered}"
}

resource "aws_iam_role_policy_attachment" "policy_attachment" {
    role                        = "${aws_iam_role.EC2toSSM_role.name}"
    policy_arn                  = "${aws_iam_policy.EC2toSSM_policy.arn}"
}
resource "aws_iam_instance_profile" "instance_profile" {
  name                          = "${var.app_name}-${var.environment}-instance-profile"
  path                          = "/"
  role                          = "${aws_iam_role.EC2toSSM_role.id}"
}
/* AMI */
data "aws_ami" "ami_linux" {
  most_recent                   = true
  owners                        = ["amazon"] # Amazon Linux 

  filter {
    name                        = "name"
    values                      = ["amzn-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name                        = "architecture"
    values                      = ["x86_64"]
  }

  filter {
    name                        = "virtualization-type"
    values                      = ["hvm"]
  }
}

/* SECURITY GROUP EC2 INSTANCE */
resource "aws_security_group" "ec2_security_group" {
  name                          = "${var.app_name}-${var.environment}-ec2-sg"
  vpc_id                        = "${var.vpc_id}"

  ingress {
    from_port                   = 22
    to_port                     = 22
    protocol                    = "tcp"
    cidr_blocks                 = "${var.admin_ips}"
  }

  ingress {
    from_port                   = 8080
    to_port                     = 8080
    protocol                    = "tcp"
    security_groups             = ["${aws_security_group.elb_security_group.id}"]
  }

  egress {
    from_port                   = 0
    to_port                     = 0
    protocol                    = "-1"
    cidr_blocks                 = ["0.0.0.0/0"]
  }

  tags {
    Name                        = "${var.app_name} ${var.environment} EC2 SG"
    Environment                 = "${var.environment}"
    Type                        = "SecurityGroup"
  }
}

/* SECURITY GROUP ELB */

resource "aws_security_group" "elb_security_group" {
  name                          = "${var.app_name}-${var.environment}-elb-sg"
  vpc_id                        = "${var.vpc_id}"

  ingress {
    from_port                   = 80
    to_port                     = 80
    protocol                    = "tcp"
    cidr_blocks                 = ["${var.users_ips}"]
  }

  egress {
    from_port                   = 0
    to_port                     = 0
    protocol                    = "-1"
    cidr_blocks                 = ["0.0.0.0/0"]
  }

  tags {
    Name                        = "${var.app_name} ${var.environment} ELB SG"
    Environment                 = "${var.environment}"
    Type                        = "SecurityGroup"
  }
}

/* EC2 INSTANCE */
resource "aws_instance" "ec2_instance" {
  ami                           = "${data.aws_ami.ami_linux.id}"
  instance_type                 = "${var.instance_type}"
  availability_zone             = "${var.ec2_availability_zone}"
  vpc_security_group_ids        = ["${aws_security_group.ec2_security_group.id}"]
  subnet_id                     = "${var.subnet_id}"
  user_data                     = "${data.template_file.userdata.rendered}"
  iam_instance_profile          = "${aws_iam_instance_profile.instance_profile.name}"
  key_name                      = "${var.key_pair_name}"

  tags {
    Name                        = "ec2-${var.app_name}-${var.environment}"
    Environment                 = "${var.environment}"
    Type                        = "EC2"
  }
}
/* EBS VOLUME */

resource "aws_ebs_volume" "ec2_instance_ebs" {
  availability_zone = "${var.ec2_availability_zone}"
  size              = "${var.ebs_volume_size}"
}
resource "aws_volume_attachment" "ec2_instance_ebs_volume_att" {
  device_name = "/dev/sdh"
  volume_id   = "${aws_ebs_volume.ec2_instance_ebs.id}"
  instance_id = "${aws_instance.ec2_instance.id}"
}

/* LOAD BALANCE */
resource "aws_elb" "instance_elb" {
  name                          = "${var.app_name}-${var.environment}-elb"
  availability_zones            = ["${var.elb_availability_zones}"]
  security_groups               = ["${aws_security_group.elb_security_group.id}"]
  cross_zone_load_balancing     = true
  connection_draining           = true
  instances                     = ["${aws_instance.ec2_instance.id}"]
  internal                      = false

  listener {
    instance_port               = 8080
    instance_protocol           = "tcp"
    lb_port                     = 80
    lb_protocol                 = "tcp"
  }

  health_check {
    healthy_threshold           = 2
    unhealthy_threshold         = 2
    interval                    = 10
    target                      = "TCP:8080"
    timeout                     = 5
  }
}
