# VPC
resource "aws_vpc" "vpc_ian" {
  cidr_block = "10.255.0.0/16"
  tags = {
    Name = "homework_ian"
  }
}

# Public Subnets
resource "aws_subnet" "public" {
  # Create one for each of the defined AZs
  for_each = var.az_list

  vpc_id = aws_vpc.vpc_ian.id
  cidr_block = "10.255.${each.key}.0/24"
  map_public_ip_on_launch = true
  availability_zone = each.value

  tags = {
    Name = "${each.value} Public"
  }
}

# IGW
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc_ian.id

  tags = {
    Name = "igw_main"
  }
}

# Route & Association
resource "aws_route_table" "default_route_igw" {
  vpc_id = aws_vpc.vpc_ian.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "Default Route IGW"
  }
}
resource "aws_route_table_association" "default" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.default_route_igw.id
}

# Instances
resource "aws_instance" "web_machines" {
  # Create one for each of the public subnets
  for_each      = aws_subnet.public
  ami           = data.aws_ami.amzlinux2.id
  instance_type = "t2.micro"
  key_name      = var.instance_keypair
  subnet_id     = each.value.id
  user_data     = file("${path.module}/webserver.sh")
  vpc_security_group_ids = [
    aws_security_group.sg_ssh.id,
    aws_security_group.sg_web.id,
  ]
  availability_zone      = each.value.availability_zone
  tags = {
    Name = "Web ${each.value.availability_zone}"
  }
}

# ALB
resource "aws_alb" "homework_ian_alb" {
  name            = "homework-ian-alb"
  security_groups = [aws_security_group.sg_web.id]
  subnets         = [for s in aws_subnet.public: s.id]
}

# ALB Target Group
resource "aws_lb_target_group" "web_tg" {
   name        = "web"
   target_type = "instance"
   port        = 80
   protocol    = "HTTP"
   vpc_id      = aws_vpc.vpc_ian.id
   health_check {
      port                = 80
      path                = "/"
      interval            = 20
      healthy_threshold   = 3
      unhealthy_threshold = 2
      timeout             = 10
  }
}

# ALB Target Group Attachment
resource "aws_lb_target_group_attachment" "web_tg_attach" {
  for_each         = aws_instance.web_machines
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = each.value.id
  port             = 80
}

# ALB Listening
resource "aws_lb_listener" "lb_listener_web" {
   load_balancer_arn    = aws_alb.homework_ian_alb.id
   port                 = "80"
   protocol             = "HTTP"
   default_action {
    target_group_arn = aws_lb_target_group.web_tg.id
    type             = "forward"
  }
}

