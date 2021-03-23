# jenkins_deployment
## Description
Deploy Jenkins on AWS
## Resources
This terraform project deploys the following resources on AWS:
* **VPC:** for the Jenkins infrastructure.
* **Internet Gateway:** to provide access to the Internet for code pull and system updates.
* **Public subnets:** to host the NAT Gateways.
* **Elastic IPs:** fot the NAT Gateways.
* **NAT Gateways:** to provide access to the internet. There is one per public subnet.
* **Private subnets:** to host the servers. The access to the Internet is through the NAT Gateways.
* **Route tables:** to properly route the traffic in the VPC.
* **ACM SSL Certificate:** for the Jenkins master web console. This certificate is also automatically validated.
* **DNS record:** for the Jenkins master web console (pointing to the application load balancer).
* **Application Load Balancer:** in a public subnet, to act as gateway to the Jenkins master and perform SSL offloading.
* **Listerners:** one to redirect HTTP traffic to use the HTTPS protocol and another to route HTTPS traffic to the target group.
* **Target Group:**: to assign the Jenkins master EC2 instance to the application load balancer.
* **Key Pair:** automatically created and attached to all instances and launch templates.
* **Instance profile:** to use SSM to connect to the instances.
* **EC2 instance:** for the Jenkins master. Provisioned using Ansible.
* **AMI:** for the Jenkins workers. Provisioned using Ansible.
* **Launch template:** for the Jenkins workers.
* **Autoscaling group:** for the Jenkins workers.
* **Autoscaling policies:** to scale up and down the number of workers.:q
* **CloudWatch alarms:** two for triggering the autoscaling policies and one for recovering the master if the instance fails.
* **Security groups:** for the application load balancer, the amster and the workers.
## Ansible configuration
Ansible is configured in the following folder: `jenkins/provisioners/ansible`
* System packages, versions, overall configurations and Jenkins plugins are configured using `jenkins_vars.yml`.
* Jenkins users are configured using `jenkins_users.yml`.
Please, note that the file containing the user credentials is an ansible vault and therefore requires a password. This password is passed to Terraform as a variable.
## Security considerations
Please, be aware that when terraform is run:
* A directory is created for the RSA keys used to access the instances.
* The Ansible vault password for the Jenkins users configuration file is saved unencrypted in a file.
## Next steps
* The handling of the password for the Ansible vault in a terraform variable needs to be improved (so it is neither saved in the state file nor logged).
* Jenkins logs should be fetched and sent to CloudWatch.
* Users in Jenkins should be configured using the Matrix Authorization strategy by default.
