output "application URL acess" {
  description = "The IP address which will be used to connect into the application"
  value       = "http://${aws_elb.instance_elb.dns_name}"
}

output "AMI_id" {
  description = "The Amazon Linux HVM x86_64 AMI ID"
  value       = "${data.aws_ami.ami_linux.id}"
}

output "jenkins_initial_password" {
  description = "Initial Jenkins admin password, I do recommend to change it after the first logon."
  value       = "${aws_ssm_parameter.jenkins_initial_password.value}"
}