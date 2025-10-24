provider "aws" {
    region = "eu-north-1"
}
resource "aws_key_pair" "devops_key" {
    key_name = "devops-key"
    public_key = file("${path.module}/devops-key.pub")
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
                sudo apt update -y
                sudo apt install docker.io -y
                sudo systemctl start docker
                sudo systemctl enable docker
                sudo usermod -aG docker ubuntu
            
                sudo apt install -y openjdk-17-jre
                curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo tee \
                    /usr/share/keyrings/jenkins-keyring.asc > /dev/null
                echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
                    https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
                    /etc/apt/sources.list.d/jenkins.list > /dev/null
                sudo apt update -y
                sudo apt install -y jenkins
                sudo systemctl enable jenkins
                sudo systemctl start jenkins
                EOF
}

# Output the public IP of the instance
output "instance_public_ip" {
    description = "Public IP of the EC2 instance"
    value = aws_instance.devops_instance.public_ip
}