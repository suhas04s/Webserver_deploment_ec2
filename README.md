# Deploying a Secure Nginx Web Server with EC2, Load Balancer, Route 53, and Certificate Manager using Terraform

Deploying a Secure Nginx Web Server on AWS with EC2, Load Balancer, Route 53, Certificate Manager Using terraform (IAc)
This guide provides step-by-step instructions to deploy a secure, scalable Nginx web server on AWS. By the end, you'll have a fully functional web application running on an EC2 instance, accessible via a custom domain name with SSL/TLS encryption.

# Prerequisites
AWS Account: Access to AWS Console.
Domain Name: Purchased domain (can be through AWS Route 53 or other domain registrars).
IAM Permissions: Sufficient permissions to create EC2, VPC, Route 53, Load Balancer, and Certificate Manager resources.

# Terraform 
1. terraform init
2. terraform plan
3. terraform apply

# Steps

1. Setting up a Virtual Private Cloud (VPC)
Navigate to the VPC Dashboard in the AWS Management Console.
Create a VPC:
Name: my-vpc
IPv4 CIDR block: 10.0.0.0/16
Create Public Subnets:
Name: my-public-subnet-1 (in us-east-1a)
CIDR block: 10.0.1.0/24
Repeat for my-public-subnet-2 (in us-east-1b) with CIDR 10.0.2.0/24
Create an Internet Gateway (IGW) and attach it to the VPC.
Update Route Table for public access:
Go to Route Tables and select the main route table.
Add a route to the Internet Gateway with destination 0.0.0.0/0.
Associate both public subnets with this route table.

2. Launching an EC2 Instance
Navigate to the EC2 Dashboard and launch an instance:
AMI: Amazon Linux 2
Instance type: t2.micro (or any suitable size)
Network: my-vpc
Subnet: my-public-subnet-1
Auto-assign Public IP: Enabled
Configure Security Group:
Allow inbound HTTP (80) and HTTPS (443) traffic from anywhere (0.0.0.0/0).
Allow SSH (22) access from a secure IP.
Connect to the EC2 Instance:
SSH into the instance using the key pair associated with the instance.

3. Installing and Configuring Nginx as a Web Server
Update Packages:
sudo yum update -y
Install Nginx:
sudo amazon-linux-extras install nginx1 -y
Start Nginx:
sudo systemctl start nginx
sudo systemctl enable nginx
Verify Installation:
Access the instance's public IP to verify Nginx is running (http://YOUR_EC2_PUBLIC_IP).

4. Setting up an AWS Load Balancer
Navigate to the EC2 Load Balancers section and create a new Load Balancer:
Type: Application Load Balancer (ALB)
Name: my-alb
Scheme: Internet-facing
Network Mapping: Select your VPC and public subnets.
Security Group: Create or choose a group allowing inbound HTTP (80) and HTTPS (443).
Configure Listeners:
Listener 1: HTTP (80)
Redirect HTTP (80) to HTTPS (443) using a listener rule.
Target Group:
Create a target group with protocol HTTP and instance target type.
Register your EC2 instance.

5. Configuring Route 53 for DNS Management
Navigate to Route 53 and create a hosted zone for your domain.
Create an A Record:
Name: www (or root domain @ if preferred)
Alias: Yes
Alias Target: Select your Application Load Balancer.
TTL: 300

6. Securing Your Domain with AWS Certificate Manager (ACM)
Navigate to Certificate Manager and request a certificate:
Choose Request a Public Certificate.
Enter your domain name (e.g., example.com and www.example.com).
Choose DNS validation.

Validate Domain Ownership:
AWS will provide CNAME records for each domain name.
Add these CNAME records to your Route 53 hosted zone.
Associate the Certificate with the Load Balancer:
Go back to your Load Balancer settings.
Update the HTTPS listener to use the newly validated certificate.

Testing
Open your browser and navigate to your domain (e.g., https://www.example.com).
Verify SSL/TLS: Ensure the connection is secure and redirects HTTP to HTTPS.

# Cleanup (Optional)
To avoid incurring charges, remember to delete all resources when you’re done:

terraform destroy

EC2 Instance
Load Balancer
Target Groups
VPC and Subnets
Certificate Manager certificates
Route 53 hosted zone

# Conclusion
You have successfully deployed a secure Nginx web server on AWS with EC2, Load Balancer, Route 53 DNS, and SSL/TLS security through Certificate Manager. This setup provides scalability, a custom domain, and secure HTTPS access for your web application.
