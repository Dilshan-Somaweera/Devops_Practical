DevOps Multi-Cloud WordPress Deployment
📋 Overview
This repository contains the implementation of a DevOps practical exam demonstrating multi-cloud expertise through Infrastructure as Code (IaC) deployment of WordPress applications across AWS and Google Cloud Platform using free-tier resources.
🏗️ Architecture
Task 01: AWS Infrastructure 
•	VPC with public/private subnets
•	EC2 t2.micro instance running WordPress
•	RDS db.t3.micro MySQL database
•	Application Load Balancer (ALB)
•	Security Groups with least privilege access

Task 02: GCP Kubernetes (GKE)
•	GKE Cluster in asia-south1-a zone
•	WordPress containerized deployment
•	MySQL with persistent storage
•	Kubernetes Secrets for database credentials
•	Network Policies for security
📁 Repository Structure
Devops_Practical/
├── task01/                 # AWS Terraform Implementation
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
├── task02/                 # GCP GKE Implementation
│   ├── terraform/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── terraform.tfvars
│   └── k8s/
│       ├── mysql-secret.yaml
│       ├── mysql-deployment.yaml
│       ├── mysql-service.yaml
│       ├── wordpress-deployment.yaml
│       ├── wordpress-service.yaml
│       └── network-policy.yaml
🚀 Quick Start
Prerequisites
•	AWS Account with free-tier eligibility
•	GCP Account with free-tier eligibility
•	AWS CLI configured
•	gcloud CLI configured
•	Terraform >= 1.0
•	kubectl installed
Task 01: AWS Deployment
1.	Clone the repository
git clone https://github.com/Dilshan-Somaweera/Devops_Practical
cd Devops_Practical/task01
2.	Configure environment variables using .env file
sample .env file
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=

Edit .env with your AWS credentials
3.	Load environment variables (PowerShell)
Get-Content .env | ForEach-Object {
  if ($_ -match "^\s*([^#].+?)\s*=\s*(.+)\s*$") {
  $key, $value = $matches[1], $matches[2]
  [System.Environment]::SetEnvironmentVariable($key, $value, "Process")
  	}}
4.	Deploy infrastructure
5.	terraform init
6.	terraform plan
7.	terraform apply
8.	Configure WordPress
o	SSH into EC2 instance using output IP
SSH Access
SSH into the EC2 instance using the public IP from Terraform output:
ssh -i your-key.pem ec2-user@<wordpress_public_ip>
Installation Commands
Run the following commands in sequence:
# Update the system
sudo yum update -y
# Install Apache, PHP, and MariaDB client
sudo yum install -y httpd php php-mysqlnd wget
sudo dnf install mariadb105
# Check MySQL client version
mysql --version
# Start and enable Apache
sudo systemctl start httpd
sudo systemctl enable httpd
# Download and extract WordPress
cd /tmp
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
# Copy WordPress files to web root
sudo cp -r wordpress/* /var/www/html/
# Set correct permissions
sudo chown -R apache:apache /var/www/html
sudo chmod -R 755 /var/www/html
# Configure wp-config.php
cd /var/www/html
cp wp-config-sample.php wp-config.php
# Edit wp-config.php using vi or nano
vi wp-config.php
WordPress Database Configuration
Inside the wp-config.php file, update these lines:
define( 'DB_NAME', 'wordpress' );
define( 'DB_USER', 'admin' );
define( 'DB_PASSWORD', 'admin123$' );
define( 'DB_HOST', 'wordpress-db.ch88mqswg697.ap-south-1.rds.amazonaws.com' );
Important: Replace the DB_HOST value with your real RDS endpoint from Terraform output.
Final Steps
Restart Apache:
sudo systemctl restart httpd
Access WordPress in your browser:
http://<alb_dns_name>
Once finished:
Use: terraform destroy 
to delete the resources and end billing
Task 02: GCP GKE Deployment
1.	Navigate to task02 directory
2.	cd ../task02
3.	Authenticate with GCP
4.	gcloud auth login
5.	gcloud config set project wordpress-setup-01
6.	Deploy GKE cluster
7.	cd terraform
8.	terraform init
9.	terraform plan
10.	terraform apply
11.	Connect kubectl to GKE
12.	gcloud container clusters get-credentials wordpress-cluster \  --zone asia-south1-a --project wordpress-setup-01
13.	Deploy Kubernetes resources
14.	cd ../k8s
15.	kubectl apply -f mysql-secret.yaml
16.	kubectl apply -f mysql-deployment.yaml
17.	kubectl apply -f mysql-service.yaml
18.	kubectl apply -f wordpress-deployment.yaml
19.	kubectl apply -f wordpress-service.yaml
20.	kubectl apply -f network-policy.yaml
21.	Access WordPress
22.	kubectl get svc wordpress
23.	# Visit the EXTERNAL-IP in your browser
💰 Cost Optimization
Free Tier Usage
AWS (12 months free):
•	EC2: 750 hours t2.micro
•	RDS: 750 hours db.t3.micro
•	ALB: 750 hours
•	EBS: 30GB GP2 storage
GCP (Always free + $300 credit):
•	Compute Engine: 1 f1-micro instance
•	GKE: Control plane free
•	Cloud SQL: db-f1-micro
•	Persistent Disk: 30GB standard
Cost Monitoring
•	Monitor AWS billing dashboard
•	Set up GCP budget alerts
•	Use terraform destroy to clean up resources
🔐 Security Implementation
AWS Security Features
•	VPC with isolated subnets
•	Security Groups with least privilege
•	IAM roles for EC2 instances
•	RDS in private subnet
•	ALB with health checks
GCP Security Features
•	Network Policies restricting pod communication
•	Kubernetes Secrets for database credentials
•	Private GKE cluster configuration
•	Firewall rules for compute instances
🔧 Troubleshooting
Common Issues
AWS:
•	Ensure SSH key pair exists in correct region
•	Verify security group rules for connectivity
•	Check RDS endpoint in wp-config.php
GCP:
•	Verify kubectl context points to correct cluster
•	Check pod logs: kubectl logs -l app=wordpress
•	Ensure LoadBalancer gets external IP
Useful Commands
# AWS
terraform show
aws ec2 describe-instances

# GCP
kubectl get pods
kubectl describe svc wordpress
gcloud compute instances list
📊 Monitoring and Logging
AWS CloudWatch
•	EC2 instance metrics
•	RDS performance insights
•	ALB access logs
GCP Monitoring
•	GKE cluster metrics
•	Container logs via Cloud Logging
•	Application performance monitoring
🧹 Cleanup
AWS
cd task01
terraform destroy
GCP
cd task02/k8s
kubectl delete -f .
cd ../terraform
terraform destroy
🎯 Learning Outcomes
This project demonstrates:
•	Infrastructure as Code with Terraform
•	Multi-cloud deployment strategies
•	Kubernetes orchestration on GKE
•	Security best practices implementation
•	Cost optimization techniques
•	Container orchestration with persistent storage
•	Network security policies
🤝 Contributing
This repository is part of a DevOps practical exam. For educational purposes, feel free to:
•	Fork the repository
•	Submit improvements via pull requests
•	Report issues or suggest enhancements
🙏 Acknowledgments
•	DevOps practical exam requirements
•	Terraform AWS and GCP providers
•	Kubernetes community documentation
•	WordPress and MySQL communities
📧 Contact
For questions or clarifications about this implementation, please open an issue in this repository.
________________________________________
Note: This implementation is designed for educational purposes and free-tier usage. For production deployments, additional security hardening, monitoring, and cost optimization measures should be implemented.

