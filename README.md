<img width="1672" height="941" alt="Project-03b-EC2-Hardening" src="https://github.com/user-attachments/assets/915d9955-d0e2-4a03-8139-7f590c2746e9" />

# Project 3b: Production-Level EC2 Security Hardening

## Overview

This project is a production-style security upgrade of my original EC2 web server project. The goal was to take a basic public EC2 web server and redesign it with stronger cloud security practices.

Instead of exposing the EC2 instance directly to the internet, I placed the web server inside a private subnet and routed all public web traffic through an Application Load Balancer. The project also used HTTPS with AWS Certificate Manager, Route 53 DNS, no public SSH access, no `.pem` key, and a NAT Gateway for private outbound internet access.

The project was deployed with Terraform, tested, documented, and then destroyed immediately to avoid unnecessary AWS charges.

---

## Main Security Goal

The main goal was to reduce the attack surface of the EC2 instance.

In the original beginner version, the EC2 instance was public and reachable directly through its public IPv4 address.

In this hardened version, the EC2 instance:

* Has no public IP address
* Is placed in a private subnet
* Does not allow SSH
* Does not use a `.pem` key
* Only accepts HTTP traffic from the Application Load Balancer security group
* Uses AWS Systems Manager Session Manager for administrative access design
* Uses NAT Gateway for outbound internet access
* Serves users through HTTPS at the load balancer layer

---

## Architecture

```text
User Browser
↓
HTTPS
↓
Route 53 DNS
↓
Application Load Balancer
↓
Private EC2 Instance
↓
Nginx Web Server
```

Full network layout:

```text
VPC
├── Public Subnet 1
│   ├── Application Load Balancer
│   └── NAT Gateway
│
├── Public Subnet 2
│   └── Application Load Balancer
│
├── Private Subnet 1
│   └── EC2 Web Server
│
└── Private Subnet 2
    └── Reserved for production-style expansion
```

---

## AWS Services Used

| Service                         | Purpose                                                               |
| ------------------------------- | --------------------------------------------------------------------- |
| Amazon VPC                      | Created an isolated cloud network                                     |
| Public Subnets                  | Hosted public-facing resources such as the ALB and NAT Gateway        |
| Private Subnets                 | Hosted the protected EC2 web server                                   |
| Internet Gateway                | Allowed public subnet resources to reach the internet                 |
| NAT Gateway                     | Allowed private subnet resources to initiate outbound internet access |
| EC2                             | Hosted the private Nginx web server                                   |
| Security Groups                 | Controlled inbound and outbound traffic                               |
| Application Load Balancer       | Served as the public entry point for web traffic                      |
| Target Group                    | Connected the ALB to the private EC2 instance                         |
| Route 53                        | Created DNS record for the application subdomain                      |
| AWS Certificate Manager         | Issued the HTTPS certificate                                          |
| IAM Role                        | Allowed the EC2 instance to use Systems Manager                       |
| Systems Manager Session Manager | Replaced SSH-based administration design                              |
| Terraform                       | Provisioned and destroyed the infrastructure as code                  |

---

## Tools Used

| Tool           | Purpose                                       |
| -------------- | --------------------------------------------- |
| Terraform      | Infrastructure as Code                        |
| AWS CLI        | AWS identity checks and resource verification |
| Git            | Local version control                         |
| GitHub         | Repository hosting                            |
| Ubuntu on WSL2 | Local development environment                 |
| VS Code        | Code editor                                   |
| Nginx          | Web server on the EC2 instance                |

---

## Security Improvements Over Project 3

| Area                    | Beginner Project 3   | Hardened Project 3b       |
| ----------------------- | -------------------- | ------------------------- |
| EC2 placement           | Public subnet        | Private subnet            |
| EC2 public IP           | Yes                  | No                        |
| SSH access              | Port 22 open         | No SSH access             |
| SSH key                 | `.pem` key used      | No `.pem` key used        |
| Web access              | Direct to EC2        | Through ALB               |
| Encryption              | HTTP only            | HTTPS with ACM            |
| DNS                     | Public IP or ALB DNS | Route 53 custom subdomain |
| Private outbound access | Not required         | NAT Gateway               |
| Admin access model      | SSH                  | Session Manager design    |
| Traffic control         | Internet to EC2      | Internet to ALB to EC2    |

---

## Security Group Design

### Application Load Balancer Security Group

Inbound:

```text
Port 80 from internet
Port 443 from internet
```

Purpose:

* Port 80 redirects users to HTTPS
* Port 443 serves encrypted web traffic

Outbound:

```text
Allowed outbound traffic from the ALB
```

### EC2 Security Group

Inbound:

```text
Port 80 only from the ALB security group
```

No inbound rule exists for:

```text
Port 22 SSH
0.0.0.0/0 direct internet access
```

Purpose:

The EC2 instance does not trust the public internet directly. It only trusts traffic forwarded from the Application Load Balancer.

---

## Why No SSH Was Used

This project intentionally avoided SSH.

Traditional SSH requires:

```text
Public or reachable network path
Port 22
Private key management
```

That creates security risks if the port is exposed or if the private key is lost, leaked, or mishandled.

Instead, this project used a production-style access design with AWS Systems Manager Session Manager.

Benefits:

* No inbound SSH port
* No `.pem` private key
* No public EC2 IP required
* Access can be controlled by IAM
* Session activity can be logged in production environments

---

## Why the EC2 Instance Was Private

The EC2 instance was placed in a private subnet to prevent direct inbound access from the internet.

This matters because public servers are constantly scanned by attackers. By removing the public IP address and allowing traffic only from the load balancer, the EC2 instance has a smaller attack surface.

The public-facing component is the Application Load Balancer, not the server itself.

---

## Why NAT Gateway Was Added

The NAT Gateway was added so the private EC2 instance could initiate outbound internet connections while still blocking unsolicited inbound internet traffic.

This matters because private servers often need outbound access for tasks such as:

* Installing packages
* Running operating system updates
* Downloading security patches
* Communicating with external services

The NAT Gateway allows this outbound access without giving the EC2 instance a public IP address.

Security tradeoff:

```text
Private EC2 can go out to the internet.
The internet cannot directly come in to the private EC2.
```

Cost tradeoff:

```text
NAT Gateway is useful and production-realistic, but it can become expensive if left running.
```

For this project, the NAT Gateway was created only for learning, tested, and then destroyed immediately.

---

## HTTPS and DNS

This project used Route 53 and AWS Certificate Manager to configure HTTPS.

The HTTP listener on the Application Load Balancer redirects traffic to HTTPS.

The HTTPS listener uses an ACM certificate and forwards encrypted user traffic to the target group.

Production pattern:

```text
HTTP port 80 → redirect to HTTPS
HTTPS port 443 → forward to private EC2 target group
```

This ensures users do not continue using unencrypted HTTP.

---

## Terraform Workflow

The project followed a safe Terraform workflow:

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
terraform destroy
```

Purpose of each step:

| Command            | Purpose                                                   |
| ------------------ | --------------------------------------------------------- |
| terraform init     | Downloads providers and initializes the working directory |
| terraform fmt      | Formats Terraform code                                    |
| terraform validate | Checks syntax and configuration validity                  |
| terraform plan     | Previews infrastructure changes before deployment         |
| terraform apply    | Creates or updates infrastructure                         |
| terraform destroy  | Removes all Terraform-managed infrastructure              |

---

## Verification Steps

After deployment, I verified that:

* The HTTPS website loaded successfully
* HTTP redirected to HTTPS
* The EC2 instance had no public IP address
* The EC2 instance was in a private subnet
* No SSH rule existed in the EC2 security group
* The EC2 security group allowed HTTP only from the ALB security group
* The ALB had listeners for HTTP and HTTPS
* The NAT Gateway existed during testing
* Terraform successfully destroyed the environment after testing

---

## Cost Control

This project included resources that can create ongoing cost if left running, especially:

* NAT Gateway
* Application Load Balancer
* EC2 instance
* Elastic IP
* EBS volume

To avoid unnecessary charges, the infrastructure was destroyed immediately after testing.

After destroying, I verified that no matching NAT Gateway or Application Load Balancer remained.

---

## Key Tradeoffs

| Decision              | Security Benefit  | Cost Impact   | Reason                                    |
| --------------------- | ----------------- | ------------- | ----------------------------------------- |
| Private EC2           | High              | Low           | Prevents direct internet exposure         |
| No SSH                | High              | Low           | Removes port 22 attack surface            |
| Session Manager       | High              | Low           | Uses IAM-based access instead of SSH keys |
| ALB                   | High              | Medium        | Provides controlled public entry point    |
| HTTPS                 | High              | Low           | Encrypts browser traffic                  |
| NAT Gateway           | Medium/High       | Higher        | Allows private outbound access            |
| Multi-AZ subnets      | High              | Low by itself | Supports production-style availability    |
| Destroy after testing | High cost control | Saves money   | Prevents unnecessary AWS charges          |

---

## Lessons Learned

This project helped me understand that production cloud security is not just about making something work. It is about designing the network so only the correct resources are exposed.

Important lessons:

* A public subnet should not automatically mean every workload is public
* EC2 instances should not be directly exposed unless there is a strong reason
* Security groups should allow only the minimum required traffic
* SSH should be avoided or tightly controlled in production
* Session Manager is a safer administrative access pattern than public SSH
* NAT Gateway allows private outbound internet access
* HTTPS should be used for public web traffic
* HTTP should redirect to HTTPS
* Terraform plans should be reviewed before applying
* Expensive resources should be destroyed after testing

---

## Final Summary

Project 3b transformed a basic EC2 web server into a production-style secured web architecture.

The final design used a private EC2 instance, public Application Load Balancer, HTTPS with ACM, Route 53 DNS, no SSH access, no public EC2 IP, IAM-based Session Manager access design, NAT Gateway for private outbound internet access, and Terraform for repeatable deployment and cleanup.

This project demonstrates practical cloud security fundamentals that are important for real cloud engineering work: reducing attack surface, separating public and private resources, controlling network traffic, encrypting web access, understanding cost tradeoffs, and safely destroying temporary infrastructure.
