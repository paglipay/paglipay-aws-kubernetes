##################################################################################
# DATA
##################################################################################

data "aws_ssm_parameter" "amzn2_linux" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

##################################################################################
# RESOURCES
##################################################################################

# INSTANCES #
resource "aws_instance" "kubmaster" {
  count                  = var.instance_count
  ami                    = nonsensitive(data.aws_ssm_parameter.amzn2_linux.value)
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnet1.id
  vpc_security_group_ids = [aws_security_group.nginx_sg.id]

  # include aws aws_key_pair.deployer.key_name
  key_name = "aws_rsa"

  # user_data = templatefile("${path.module}/templates/userdata.sh", {
  #   playbook_repository = var.playbook_repository
  #   secret_id           = var.api_key_secret_id
  #   host_list_ssm_name  = local.host_list_ssm_name
  #   site_name_ssm_name  = local.site_name_ssm_name
  # })
  
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("aws_rsa.pem")
    host        = aws_instance.nginx1.public_ip
  }

 

  provisioner "file" {
    source      = "../ansible"
    destination = "/home/ec2-user/ansible"
  } 
  
  provisioner "file" {
    source      = "./aws_rsa.pem"
    destination = "/home/ec2-user/ansible/aws_rsa.pem"
  }
  
  provisioner "file" {
    source      = "../ansible/ansible.cfg"
    destination = "/home/ec2-user/ansible.cfg"
  }

  provisioner "file" {
    source      = "../templates/userdata.sh"
    destination = "/home/ec2-user/userdata.sh"
  }

  provisioner "file" {
    source      = "../spring-demo"
    destination = "/home/ec2-user/spring-demo"
  }

  provisioner "file" {
    source      = "../Dockerfile"
    destination = "/home/ec2-user/Dockerfile"
  }

  # add remote exec configuration
  provisioner "remote-exec" {

    inline = [
      "sudo yum update -y",
      "sudo amazon-linux-extras install -y ansible2",
      # "pwd",
      # "ls -la",
      "sudo chmod 600 ansible/aws_rsa.pem && ansible-playbook -i ansible/hosts --private-key ansible/aws_rsa.pem ansible/playbook.yml",
      "ansible-playbook -i ansible/hosts --private-key ansible/aws_rsa.pem ansible/maven_build_playbook.yml",
      # "chmod +x /home/ec2-user/userdata.sh",
      # "sh /home/ec2-user/userdata.sh",
      # "sudo yum install -y maven",
      # "unzip /spring-demo.zip",  # Assuming project is transferred beforehand
      # "cd spring-demo",
      # "mvn clean install",
      
      # "sudo yum install -y docker",
      "sudo usermod -a -G docker ec2-user",
      "sudo yum install -y python3-pip",
      # "sudo pip3 install -y docker-compose",
      "sudo systemctl enable docker.service",
      "sudo systemctl start docker.service",

      "sudo docker build -t paglipay/spring-demo:latest .",
      "sudo docker run --rm -it -d -p 80:5000/tcp paglipay/spring-demo:latest"
    ]
    on_failure = continue
  }

#   user_data = <<EOF
# #! /bin/bash
# sudo amazon-linux-extras install -y nginx1
# sudo service nginx start
# sudo rm /usr/share/nginx/html/index.html
# echo '<html><head><title>Taco Team Server 1</title></head><body style=\"background-color:#1F778D\"><p style=\"text-align: center;\"><span style=\"color:#FFFFFF;\"><span style=\"font-size:28px;\">You did it! Have a &#127790;</span></span></p></body></html>' | sudo tee /usr/share/nginx/html/index.html
# EOF

  tags = local.common_tags

resource "aws_iam_role_policy" "allow_s3_all" {
  name = "${local.naming_prefix}-allow_s3_all"
  role = aws_iam_role.allow_nginx_s3.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": [
                "arn:aws:s3:::${local.s3_bucket_name}",
                "arn:aws:s3:::${local.s3_bucket_name}/*"
            ]
    }
  ]
}
EOF

}

# resource "aws_instance" "nginx2" {
#   ami                    = nonsensitive(data.aws_ssm_parameter.amzn2_linux.value)
#   instance_type          = var.instance_type
#   subnet_id              = aws_subnet.public_subnet2.id
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

#   provisioner "file" {
#     source      = "../spring-demo"
#     destination = "/home/ec2-user/spring-demo"
#   }

#   provisioner "file" {
#     source      = "../Dockerfile"
#     destination = "/home/ec2-user/Dockerfile"
#   }

#   # add remote exec configuration
#   provisioner "remote-exec" {

#     inline = [
#       "sudo yum update -y",
#       "sudo yum install -y docker",
#       "sudo usermod -a -G docker ec2-user",
#       "sudo yum install -y python3-pip",
#       "sudo systemctl enable docker.service",
#       "sudo systemctl start docker.service",
#       "sudo docker build -t paglipay/spring-demo:latest .",
#       "sudo docker run --rm -it -d -p 80:5000/tcp paglipay/spring-demo:latest"
#     ]
#     on_failure = continue
#   }

# #   user_data = <<EOF
# # #! /bin/bash
# # sudo amazon-linux-extras install -y nginx1
# # sudo service nginx start
# # sudo rm /usr/share/nginx/html/index.html
# # echo '<html><head><title>Taco Team Server 1</title></head><body style=\"background-color:#1F778D\"><p style=\"text-align: center;\"><span style=\"color:#FFFFFF;\"><span style=\"font-size:28px;\">You did it! Have a &#127790;</span></span></p></body></html>' | sudo tee /usr/share/nginx/html/index.html
# # EOF

#   tags = local.common_tags

# }