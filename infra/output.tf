output "instance_public_address" {
  value = "${aws_instance.web.public_dns}"
}

output "sns_topic_arn" {
  value = "${aws_sns_topic.test.arn}"
}

output "sqs_queue_name" {
  value = "${aws_sqs_queue.example.name}"
}
