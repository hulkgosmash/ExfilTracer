output "A_Connect_to_instance_with" {
  value = "ssh ubuntu@exfiltracer${var.client_ID}.${var.root_domain}"
  description = "Test the description field"
}
output "B_IP_Address" {
  value = "${aws_instance.ExfilTracer.public_ip}"
}
output "C_Domain_Name" {
  value = "exfiltracer${var.client_ID}.${var.root_domain}"
}