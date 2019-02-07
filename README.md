# Devops_test
Terraform code which creates an EC2 instance with Jenkins 

## Module usage

CLONE REMOTE REPOSITORY TO YOUR LOCAL MACHINE

```hcl
git clone git@github.com:fabianobianchi/devops_test.git
```

EDIT MODULE_JENKINS.TF FILE INSERTING YOUR CUSTOM VARIABLES AS THE FOLLOWING EXAMPLE 
```hcl
module "Ci-cd" {
  source = "git@github.com:fabianobianchi/devops_test.git"

  aws_region                = "us-east-1"
  ec2_availability_zone     = "us-east-1a"
  elb_availability_zones    = "us-east-1a"
  vpc_id                    = "vpc-98cab1e3"
  subnet_id                 = "subnet-00978e2f"
  key_pair_name             = "development"
}
```
INITIALIZE TERRAFORM
```hcl
Terrafom init
```
PLAN CHANGES
```hcl
Terrafom plan
```
APPLY CHANGES
```hcl
Terraform apply
```

## Variables

| Name | Description | Type | Default value |Required |
|------|-------------|------|---------------|---------|
| aws_region | Choose the AWS Region to run the environment | String | - | *YES* |
| app_name | The application name which will also name the resources | String | "Jenkins" | NO |
| environment | The environment name which will run the application | String | "development" | NO |
| vpc_id | The AWS VPC id | String | - | YES |
| admin_ips | IP address list to limit SSH access to EC2 instance | List | ["0.0.0.0/0"] | NO |
| users_ips | IP address list to limit WEB access to Jenkins | List | ["0.0.0.0/0"] | NO |
| instance_type | Instance size of EC2 instance | String | "t2.small" | NO |
| ec2_availability_zone | AWS availability zone which EC2 will run in | String | - | *YES* |
| subnet_id | AWS subnet id, Public subnet will allow external access, Private subnet will allow SSH access only via bastion server | String | - | *YES* |
| key_pair_name | AWS Key pair, please create the key before this installation and provide de key name | String | - | *YES* |
| ebs_volume_size | EBS volume size which will be attached to EC2 instance | String | "20" | NO |
| elb_availability_zones | Availability zones list which ELB will distribute the traffic | String | - | *YES* |

## Outputs

| Name | Description |
|------|-------------|
| application URL address | ELB address to access the applicaton |
| jenkins_initial_password | Information about how to find the Initial Jenkins password in a easy way |

To access the application URL address and Jenkins initial Password, please login into AWS console and go to *EC2 --> PARAMETER STORE* and find the */jenkins/url_address* and */jenkins/initial_password* parameters value to access the information in an easy way.

## Features added

### ELB instead of Elastic IP address

The test requested to create an environment using elastic IP address however I decided to increment the solution and implement an ELB due to the fact that redirect http protocol to 8080 (Default Jenkins port) making the user experience better to use it. In addition, the security group was configured in order to only ELB have Web access to the application, increasing the security level.

### SSM Parameter

A SSM parameter was created to store initial Jenkins password and Jenkins URL address, this feature makes easier and faster to use the app, the original solution require to logon into the instance to find the initial password and find the Load Balance address in AWS console. The password uses securestring to protect its value, only AWS users with access into the SSM can extract the password. I recommend to change the password after the first login.

### Security

The script allows to define IPs from users to access the application and IPs from administrator to access the EC2 console, security groups were configured to restrict access into the EC2 instance. In addition, the scripts are using the default images from Amazon (EC2) and Jenkins Ocean blue (Jenkins).
The solution uses role to allow permissions following the AWS best practices.

## Future features

### Bastion server

Create a bastion server to provide SSH connection to the EC2 instance, the bastion server will allow that EC2 be protected inside Private subnet and also provide a secure SSH access to administrators

### Slave Jenkins servers

Include slave Jenkins servers in case of needs to run jobs accross different platforms or to distribute the load.

### Persistent model

This project needs to be updated to run into a production environment, due to the fact that after EC2 reinicialization administrators have to manually rerun docker command to start Jenkins, this behaviour is not acceptable for production environment.

### Backup and persist application data

I recommend to implement a backup job to prevent Jenkins configuration loss.

## Author 

Fabiano Bianchi

personal email: bianchi_fabiano@yahoo.com.br

## Code version 

0.1



