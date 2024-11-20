// 1. security group for ALB (Internet --> ALB)
resource "aws_security_group" "alb_sg" {
  description = "Security group for Application Load Balancer"
  vpc_id      = aws_vpc.custom_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "yt-alb-sg"
  }
}

// 2. Security group for EC2 instance (ALB --> EC2)

resource "aws_security_group" "ec2_sg" {
  description = "Security group for Web Server Instance"
  vpc_id      = aws_vpc.custom_vpc.id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "yt-ec2-sg"
  }
}



// 3. Appliction load balancer 

resource "aws_lb" "app_lb" {
  name               = "yt-app-lb"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = aws_subnet.public_subnet[*].id
  depends_on         = [aws_internet_gateway.igw_vpc]
}

// target group for alb

resource "aws_lb_target_group" "alb_ec2_tg" {
  port     = "80"
  protocol = "HTTP"
  vpc_id   = aws_vpc.custom_vpc.id
  tags = {
    Name = "yt-alb-ec2-tg"
  }

}

// listner

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_ec2_tg.arn
  }
  tags = {
    Name = "yt-alb-listner"
  }
}

// lunch templete for ec2

resource "aws_launch_template" "ec2-lunch-templete" {
  name = "yt-web-server"

  image_id      = "ami-0866a3c8686eaeeba"
  instance_type = "t2.micro"

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = aws_security_group.ec2_sg.id
  }

  user_data = filebase64("script.sh")

  tag_specifications {

    resource_type = "instance"
    tags = {
      Name = "yt-ec2-web-server"
    }
  }

}

// auto scaling group 

resource "aws_autoscaling_group" "ec2-asg" {
  max_size            = 3
  min_size            = 2
  desired_capacity    = 1
  name                = "yt-web-server-asg"
  target_group_arns   = [aws_lb_target_group.alb_ec2_tg.arn]
  vpc_zone_identifier = aws_subnet.public_subnet[*].id

  launch_template {
    id      = aws_launch_template.ec2-lunch-templete.id
    version = "$Latest"
  }

  health_check_type = "EC2"
}


output "alb_dns_name" {
  value = aws_lb.app_lb.dns_name

}