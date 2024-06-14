output "A_Connect_to_instance_with" {
  value = "ssh -i ${var.Private_key} ubuntu@${aws_instance.ExfilTracer.public_ip}"
  description = "Test the description field"
}
output "B_IP_Address" {
  value = "${aws_instance.ExfilTracer.public_ip}"
}

