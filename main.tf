provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "test" {
  ami                    = "ami-0dfcb1ef8550277af"
  instance_type          = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.instance.id}"]
  tags = {
    Name = "terraform-test"
  }
  user_data = <<-EOF
    #!/bin/bash
sudo yum install httpd -y
sudo systemctl start httpd
sudo systemctl enable httpd
echo "Hello, world" | sudo tee /var/www/html/index.html
    EOF
}
resource "aws_security_group" "instance" {
  name = "terraform-test-instance"

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
variable "server_port" {
  description = "The port the server will use for HTTP requests"
  default     = 8080
}
output "public_ip" {
  value = aws_instance.test.public_ip
}
