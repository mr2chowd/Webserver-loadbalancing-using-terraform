# Terraform project on AWS

## Set up AWS on your CLI

-   Login in to your AWS account and click on the right on your name. 
-   Then click on the security credentials on the tab, which will take you to IAM credentials. 
-   Scroll down to access keys
-   Click on create access key 
-   Choose your usecase of CLI and keep the keys 

Open VS code or git bash or any command line tool you want to use, then : 

-   Command in "aws configure"
-   Type in your access code and security key or you can just copy paste it
-   Choose your desired AWS Region for example us-east-1 
-   Json output format can be choosen

And, your CLI is all set up. 

## SETUP TERRAFORM PROVIDERS 

Terraform has probably one of the best documentation in the devops space. So I highly recommend using their documentations frequently to avoid mistakes or using older versioning. 

Go to following link: 

[AWS PROVIDER LINK ON HASHICORP TERRAFORM](https://registry.terraform.io/providers/hashicorp/aws/latest)

You will find an option "use provider , clisk on it and copy the code from "How to use this provider". 

A format like this will appear: 

```
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.56.1"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
```

Copy past it and create a file named "provider.tf"

### Check if terraform is installed and initialize it

Type in the following command : 

```
terraform init

```
### Creating a VPC in terraform 

You can go to your AWS console and try using the console to see the key inputs you need to create a VPC along with the {[hashicorp guidelines](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc)}

Do not forget to save all your variables in variables.tf so that you can easily reference them using "var."
Key features of the VPC: 
- cidr_block 
- tag 

### Creating an aws_subnet 
