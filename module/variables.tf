
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
variable "availability_zone" {
  description   = "AWS availability zone which the solution will run in"
}
variable "subnet_id" {
  description   = "AWS public subnet id which will host the EC2 instance"
}
variable "key_pair_name" {
  description   = "SSH key pair to allow connection to the instance"  
}
variable "ebs_volume_size" {
  description   = "EBS volume size" 
  default       = "20"
}
