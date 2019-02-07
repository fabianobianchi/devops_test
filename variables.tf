
variable "aws_region" {
  description   = "AWS region"  
}
variable "app_name" {
  description   = "Application name"
  default       = "Jenkins"   
}
variable "environment" {
  description   = "Set a environment name"
  default       = "development"
}
variable "vpc_id" {
  description   = "The AWS virtual Private Cloud id"    
}
variable "admin_ips" {
  description   = "Ip address from administrators which have access to EC2 Console"
  default       = ["0.0.0.0/0"]   
}
variable "users_ips" {
  description   = "Ip address from users which have access to the app"  
  default       = ["0.0.0.0/0"] 
}
variable "instance_type" {
  description   = "The instance type"
  default       = "t2.small"    
}
variable "ec2_availability_zone" {
  description   = "AWS availability zone which EC2 will run"
}
variable "subnet_id" {
  description   = "AWS subnet id which will host the EC2 instance, to allow SSH over the internet insert a public subnet or use a bastion server to connect into a private subnet"
}
variable "key_pair_name" {
  description   = "SSH key pair to allow connection to the instance"  
}
variable "ebs_volume_size" {
  description   = "EBS volume size" 
  default       = "20"
}

variable "elb_availability_zones" {
  description   = "Availability zones which ELB will distribute the traffic"    
}
variable "ec2tossm_role_file" {
  description   = "Json file name to create a role which allow EC2 Jenkins instance to access SSM"
  default       = "ec2toSSM_role.json"
}
variable "ec2tossm_policy_file" {
  description   = "Json file name to create a policy which allow EC2 Jenkins instance to access SSM"
  default       = "ec2toSSM_policy.json"
}

