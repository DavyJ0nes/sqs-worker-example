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
