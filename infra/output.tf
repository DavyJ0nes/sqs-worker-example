output "instance_public_address" {
  value = "${aws_instance.web.public_dns}"
}
