terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}

resource "aws_instance" "example" {
  ami           = "ami-0fb653ca2d3203ac1"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.instance.id] #provider_type.name.attribute

  user_data = <<-EOF
                #!/bin/bash
                echo "Hello World" > index.html
                nohup busybox httpd -f -p 8080&
                EOF
            
  user_data_replace_on_change = true

  tags = {
    Name= "terraform-example"
  }
}

#security group is needed to allow any incoming or outgoing traffic from EC2 Instance
resource "aws_security_group" "instance"{
    name = "terraform-example-instance"

    ingress{
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

output "public_ip" {
  value       = aws_instance.example.public_ip
  description = "The public IP of the Instance"
}