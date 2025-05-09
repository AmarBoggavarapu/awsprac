resource "aws_vpc" "myvpc" {
  cidr_block = var.cidr
  tags = {
    "Name" = "myvpc"
  }
}

resource "aws_subnet" "mysubnet1" {
  vpc_id = aws_vpc.myvpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    "Name" = "mysubnet1"
  }
}

resource "aws_subnet" "mysubnet2" {
  vpc_id = aws_vpc.myvpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    "Name" = "mysubnet2"
  }
}


resource "aws_internet_gateway" "myigw" {
  vpc_id = aws_vpc.myvpc.id
  tags = {
    "Name" = "myigw"
  }
}


resource "aws_route_table" "myrt" {
  vpc_id = aws_vpc.myvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myigw.id
  }
  tags = {
    "Name" = "myrt"
  }
}

resource "aws_route_table_association" "myrta1" {
  subnet_id = aws_subnet.mysubnet1.id
  route_table_id = aws_route_table.myrt.id
}


resource "aws_route_table_association" "myrta2" {
  subnet_id = aws_subnet.mysubnet2.id
  route_table_id = aws_route_table.myrt.id
}


resource "aws_security_group" "mysg" {
  name = "mysg"
  description = "Allow HTTP & TCP traffic"
  vpc_id = aws_vpc.myvpc.id
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    "Name" = "mysg"
  }
}

resource "aws_s3_bucket" "mys3bucket" {
  bucket = "amarbvn-tf-prac-s3"
  tags = {
    "Name" = "mys3bucket"
  }
}

resource "aws_instance" "tfprac-ec2instance1" {
  ami = "ami-084568db4383264d4"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.mysubnet1.id
  vpc_security_group_ids = [aws_security_group.mysg.id]
  key_name = "amarbvn-tf-prac"
  tags = {
    "Name" = "tfprac-ec2instance1"
  }
  user_data = base64encode(file("startup_script1.sh"))
}


resource "aws_instance" "tfprac-ec2instance2" {
  ami = "ami-084568db4383264d4"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.mysubnet2.id
  vpc_security_group_ids = [aws_security_group.mysg.id]
  key_name = "amarbvn-tf-prac"
  tags = {
    "Name" = "tfprac-ec2instance2"
  }
  user_data = base64encode(file("startup_script2.sh"))
}


resource "aws_lb" "mylb" {
  name = "mylb"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.mysg.id]
  subnets = [aws_subnet.mysubnet1.id, aws_subnet.mysubnet2.id]
  tags = {
    "Name" = "mylb"
  }
}



resource "aws_lb_target_group" "mytg" {
  name = "mytg"
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.myvpc.id
  health_check {
    path = "/"
    port = "traffic-port"
  }
  tags = {
    "Name" = "mytg"
  }
}

resource "aws_lb_target_group_attachment" "mytgattachment1" {
  target_group_arn = aws_lb_target_group.mytg.arn
  target_id = aws_instance.tfprac-ec2instance1.id
  port = 80
}

resource "aws_lb_target_group_attachment" "mytgattachment2" {
  target_group_arn = aws_lb_target_group.mytg.arn
  target_id = aws_instance.tfprac-ec2instance2.id
  port = 80
}


resource "aws_lb_listener" "mylistener" {
  load_balancer_arn = aws_lb.mylb.arn
  port = 80
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.mytg.arn
  }
}


output "loadbalancerdns" {
  value = aws_lb.mylb.dns_name
}

