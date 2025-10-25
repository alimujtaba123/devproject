provider "aws" {
    region = "eu-north-1"
}
resource "aws_key_pair" "devops_key" {
    key_name = "devops-key"
    public_key = file("${path.module}/devops-key.pub")
}
resource "aws_eip" "devops_eip" {
  instance = aws_instance.devops_instance.id
}
output "elastic_ip" {
  value = aws_eip.devops_eip.public_ip
}

resource "aws_security_group" "devops_sg" {
    name = "devops-sg"
    description = "Allow SSH, HTTP, Jenkins, and K8s ports"

    ingress{
        description = "Allow SSH"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress{
        description = "Allow HTTP"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        description = "Allow Jenkins"
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        description = "Allow K8s API Server"
        from_port = 6443
        to_port = 6443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
resource "aws_instance" "devops_instance" {
    ami      ="ami-0a716d3f3b16d290c"
    instance_type = "m7i-flex.large"
    key_name = aws_key_pair.devops_key.key_name
    security_groups = [aws_security_group.devops_sg.name]
    tags ={
        Name = "Devops-Project-Instance"
    }
    user_data = <<-EOF
                #!/bin/bash
                # Update system
                sudo apt update -y
                sudo apt upgrade -y

                # Install Docker and Git
                sudo apt install -y docker.io git
                sudo systemctl enable docker
                sudo systemctl start docker
                sudo usermod -aG docker ubuntu

                # Install Java
                sudo apt install -y fontconfig openjdk-17-jre gnupg2 curl

                # Add Jenkins key and repo (for Ubuntu 24.04+)
                sudo mkdir -p /usr/share/keyrings
                curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2023.key | sudo tee \
                    /usr/share/keyrings/jenkins-keyring.asc > /dev/null

                echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
                    https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
                    /etc/apt/sources.list.d/jenkins.list > /dev/null

                # Install Jenkins
                sudo apt update -y
                sudo apt install -y jenkins

                # Enable and start Jenkins
                sudo systemctl enable jenkins
                sudo systemctl start jenkins            
                EOF
}

# Output the public IP of the instance
output "instance_public_ip" {
    description = "Public IP of the EC2 instance"
    value = aws_instance.devops_instance.public_ip
}