data "aws_ami" "amazon-linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

# Security Group
resource "aws_security_group" "http-and-ssh" {
  name        = "allow_all"
  description = "Allow all inbound traffic"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.my_ip}"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.my_ip}"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"] 
  }

  tags {
    Name = "http-ssh"
  }
}

# Create a web server
resource "aws_instance" "web" {
  ami           = "${data.aws_ami.amazon-linux.id}"
  instance_type = "t2.micro"
  iam_instance_profile = "${aws_iam_instance_profile.profile.name}"

  key_name   = "${var.key_name}"
  monitoring = false
  vpc_security_group_ids = ["${aws_security_group.http-and-ssh.id}"]

  user_data = <<EOF
    #!/bin/bash
    yum update
    yum install -y docker go
EOF

  tags {
    Name        = "Queue Worker"
    Environment = "test"
  }
}
