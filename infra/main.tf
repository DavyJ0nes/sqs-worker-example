provider "aws" {
  region     = "${var.aws_region}"
}

# SNS Topic
resource "aws_sns_topic" "test" {
  name = "test-topic"
}

# SQS Queue
resource "aws_sqs_queue" "example" {
  name                      = "example-queue"
  delay_seconds             = 5
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10

  tags {
    Environment = "test"
  }
}

# Subscribe SQS to SNS Topic
resource "aws_sns_topic_subscription" "test-example" {
  topic_arn = "${aws_sns_topic.test.arn}"
  protocol  = "sqs"
  endpoint  = "${aws_sqs_queue.example.arn}"
}

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

# IAM Role
resource "aws_iam_role" "sqs_read" {
  name = "sqs_read"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# IAM Policy Send Message to Topic and Read from SQS
resource "aws_iam_role_policy" "demo_policy" {
  name = "demo_policy"
  role = "${aws_iam_role.sqs_read.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "sqs:DeleteMessage",
                "sqs:ListQueues",
                "sqs:GetQueueUrl",
                "sns:GetTopicAttributes",
                "sqs:SendMessageBatch",
                "sqs:ReceiveMessage",
                "sqs:SendMessage",
                "sns:ListTopics",
                "sqs:GetQueueAttributes",
                "sns:Publish",
                "sqs:ListDeadLetterSourceQueues",
                "sqs:DeleteMessageBatch",
                "sns:Subscribe"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_instance_profile" "profile" {
  name = "sqs-sns-role"
  role = "${aws_iam_role.sqs_read.id}"
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
