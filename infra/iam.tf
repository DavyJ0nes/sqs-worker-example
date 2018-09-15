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
