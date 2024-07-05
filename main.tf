resource "aws_vpc" "tproject" {
    cidr_block = var.cidr_block_vpc
}

resource "aws_subnet" "tsubnet1" {
  vpc_id = aws_vpc.tproject.id
  cidr_block = var.cidr_block_subnet1
  availability_zone = var.availability_zone
  map_public_ip_on_launch = true
}

resource "aws_subnet" "tsubnet2" {
  vpc_id = aws_vpc.tproject.id
  cidr_block = var.cidr_block_subnet2
  availability_zone = var.availability_zone
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "tinternetgateway" {
  vpc_id = aws_vpc.tproject.id
}

resource "aws_route_table" "troutetable" {
    vpc_id = aws_vpc.tproject.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.tinternetgateway.id
    }
}
resource "aws_route_table_association" "rta1" {
    subnet_id = aws_subnet.tsubnet1.id
    route_table_id = aws_route_table.troutetable.id
  
}
resource "aws_route_table_association" "rta2" {
    subnet_id = aws_subnet.tsubnet2.id
    route_table_id = aws_route_table.troutetable.id
  
}

resource "aws_security_group" "websg" {
  name        = "websg"
  description = "Security group for webserver"
  vpc_id      = aws_vpc.tproject.id
  tags = {
    Name = "websg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.websg.id
  description = "HTTP WEBSERVER"

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.websg.id
  description = "ssh"
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
}

resource "aws_vpc_security_group_egress_rule" "ssh" {
  security_group_id = aws_security_group.websg.id
  description = "all allow traffic egress"
  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}

resource "aws_s3_bucket" "test_t_2473" {
  bucket = "mochowdhury-my-tf-bucket"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

resource "aws_instance" "webserver1" {
  ami                    = "ami-0261755bbcb8c4a84"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.websg.id]
  subnet_id              = aws_subnet.tsubnet1.id
  user_data              = base64encode(file("userdata.sh"))
}

resource "aws_instance" "webserver2" {
  ami                    = "ami-0261755bbcb8c4a84"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.websg.id]
  subnet_id              = aws_subnet.tsubnet2.id
  user_data              = base64encode(file("userdata2.sh"))
}
resource "aws_lb" "weblb" {
    name = "webalb"
    internal = false 
    load_balancer_type = "application"
    security_groups = [aws_security_group.websg.id]
    subnets = [aws_subnet.tsubnet1.id,aws_subnet.tsubnet2.id]
    tags = {
        Name = "web"
    }
}

resource "aws_lb_target_group" "tg" {
  name     = "myTG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.tproject.id

  health_check {
    path = "/"
    port = "traffic-port"
  }
}

resource "aws_lb_target_group_attachment" "attach1" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.webserver1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "attach2" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.webserver2.id
  port             = 80
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.weblb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.tg.arn
    type             = "forward"
  }
}

output "loadbalancerdns" {
  value = aws_lb.weblb.dns_name
}