module "Ci-cd" {
  source                    = "git@github.com:fabianobianchi/devops_test.git//module"
  aws_region                = "us-east-1"
  ec2_availability_zone     = "us-east-1a"
  elb_availability_zones    = "us-east-1a"
  vpc_id                    = "vpc-98cab1e3"
  subnet_id                 = "subnet-00978e2f"
  key_pair_name             = "Singapura"
}