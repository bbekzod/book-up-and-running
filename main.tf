

resource "aws_launch_configuration" "example" {
  image_id        = "ami-0dfcb1ef8550277af"
  instance_type   = "t2.micro"
  security_groups = ["${aws_security_group.instance.id}"]


  user_data = <<-EOF
    #!/bin/bash
     sudo yum install httpd -y
     sudo systemctl start httpd
     sudo systemctl enable httpd
     echo "Hello, world" | sudo tee /var/www/html/index.html
    EOF


  lifecycle {
    create_before_destroy = true
  }
}




resource "aws_autoscaling_group" "example" {
  launch_configuration = aws_launch_configuration.example.id
  availability_zones   = data.aws_availability_zones.all.names


  load_balancers    = ["${aws_elb.example.name}"]
  health_check_type = "ELB"


  min_size = 2
  max_size = 10

  tag {
    key                 = "Name"
    value               = "terraform-asg-example"
    propagate_at_launch = true
  }
}


