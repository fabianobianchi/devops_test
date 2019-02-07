module "ci_cd" {
  source                    = "git@github.com:fabianobianchi/devops_test.git//module?ref=fix/output"
  aws_region                = "us-east-1"
  availability_zone         = "us-east-1a"
  vpc_id                    = "vpc-98cab1e3"
  subnet_id                 = "subnet-00978e2f"
  key_pair_name             = "Singapura"
}
output "application_url_access" {
  value = "${module.ci_cd.application_url_access}"
}

output "jenkins_initial_password" {
  value = "${module.ci_cd.jenkins_initial_password}"
 }

