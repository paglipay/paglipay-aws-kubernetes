# ##################################################################################
# # PROVIDERS
# ##################################################################################

# provider "aws" {
#   #  access_key = "AKIASWK2AEZTKDWMVD5D"
#   #  secret_key = "SECRET_KEY"
#   region = "us-east-1"
# }

# ##################################################################################
# # DATA
# ##################################################################################

# data "aws_ssm_parameter" "amzn2_linux" {
#   name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"

# }


# ##################################################################################
# # RESOURCES
# ##################################################################################

# # NETWORKING #
# resource "aws_vpc" "app" {
#   cidr_block           = "10.0.0.0/16"
#   enable_dns_hostnames = true

# }

# resource "aws_internet_gateway" "app" {
#   vpc_id = aws_vpc.app.id

# }

# resource "aws_subnet" "public_subnet1" {
#   cidr_block              = "10.0.0.0/24"
#   vpc_id                  = aws_vpc.app.id
#   map_public_ip_on_launch = true
# }

# # ROUTING #
# resource "aws_route_table" "app" {
#   vpc_id = aws_vpc.app.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.app.id
#   }
# }

# resource "aws_route_table_association" "app_subnet1" {
#   subnet_id      = aws_subnet.public_subnet1.id
#   route_table_id = aws_route_table.app.id
# }

# # SECURITY GROUPS #

# # Nginx security group 
# resource "aws_security_group" "nginx_sg" {
#   name   = "nginx_sg"
#   vpc_id = aws_vpc.app.id

#   # HTTP access from anywhere
#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   # HTTP access from anywhere
#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   # HTTP access from anywhere
#   ingress {
#     from_port   = 8080
#     to_port     = 8080
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   # HTTP access from anywhere
#   ingress {
#     from_port   = 8000
#     to_port     = 8000
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   # HTTP access from anywhere
#   ingress {
#     from_port   = 9001
#     to_port     = 9001
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   # HTTP access from anywhere
#   ingress {
#     from_port   = 9443
#     to_port     = 9443
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   # HTTP access from anywhere
#   ingress {
#     from_port   = 8081
#     to_port     = 8081
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   # HTTP access from anywhere
#   ingress {
#     from_port   = 5001
#     to_port     = 5001
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   # outbound internet access
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# # INSTANCES # https://dev.to/aws-builders/installing-jenkins-on-amazon-ec2-491e
# resource "aws_instance" "nginx1" {
#   ami                    = nonsensitive(data.aws_ssm_parameter.amzn2_linux.value)
#   instance_type          = "t2.micro"
#   subnet_id              = aws_subnet.public_subnet1.id
#   vpc_security_group_ids = [aws_security_group.nginx_sg.id]

#   # include aws aws_key_pair.deployer.key_name
#   key_name = "aws_rsa"
  
#   connection {
#     type        = "ssh"
#     user        = "ec2-user"
#     private_key = file("aws_rsa.pem")
#     host        = aws_instance.nginx1.public_ip
#   }

#   provisioner "file" {
#     source      = "../ansible"
#     destination = "/home/ec2-user/ansible"
#   }

#   provisioner "file" {
#     source      = "../templates/userdata.sh"
#     destination = "/home/ec2-user/userdata.sh"
#   }

#   # add remote exec configuration
#   provisioner "remote-exec" {

#     inline = [
#       "sudo yum update -y",
#       "sudo amazon-linux-extras install -y ansible2",
#       "pwd",
#       "ls -la",
#       "ansible-playbook -i ansible/hosts ansible/playbook.yml",
#       "chmod +x /home/ec2-user/userdata.sh",
#       "sh /home/ec2-user/userdata.sh",
#     ]
#     on_failure = continue
#   }

# }

# #resource "aws-s3-bucket" "jenkins-artifact20-s3" {
# #  bucket = "jenkins-artifact20-s3"
# #}
