variable "aws_region" {
  description = "AWS region where the project resources will be deployed."
  type        = string
  default     = "us-east-2"
}

variable "project_name" {
  description = "Project name used for tagging and naming AWS resources."
  type        = string
  default     = "resil-project-03b"
}

variable "vpc_cidr" {
  description = "CIDR block for the custom VPC."
  type        = string
  default     = "10.30.0.0/16"
}

variable "public_subnet_1_cidr" {
  description = "CIDR block for the first public subnet."
  type        = string
  default     = "10.30.1.0/24"
}

variable "public_subnet_2_cidr" {
  description = "CIDR block for the second public subnet."
  type        = string
  default     = "10.30.2.0/24"
}

variable "private_subnet_1_cidr" {
  description = "CIDR block for the first private subnet."
  type        = string
  default     = "10.30.11.0/24"
}

variable "private_subnet_2_cidr" {
  description = "CIDR block for the second private subnet."
  type        = string
  default     = "10.30.12.0/24"
}

variable "instance_type" {
  description = "EC2 instance type for the private web server."
  type        = string
  default     = "t3.micro"
}
variable "root_domain_name" {
  description = "Root domain name hosted in Route 53."
  type        = string
  default     = "tenglee.dev"
}

variable "app_domain_name" {
  description = "Subdomain used for the hardened EC2 web app."
  type        = string
  default     = "project3b.tenglee.dev"
}
