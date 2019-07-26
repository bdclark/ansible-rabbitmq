output "rabbitmq_security_group_id" {
  value = "${aws_security_group.rabbitmq.id}"
}

output "consul_public_ip" {
  value = "${aws_instance.consul.public_ip}"
}

output "rabbitmq_public_ips" {
  value = "${aws_instance.rabbitmq.*.public_ip}"
}
