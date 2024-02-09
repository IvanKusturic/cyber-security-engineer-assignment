output "wireguard_public_ip" {
  value = aws_eip.wireguard_public_ip.public_ip
}

output "wireguard_private_ip" {
  value = aws_instance.ec2_wireguard.private_ip
}

output "http_server_private_ip" {
  value = aws_instance.ec2_http.private_ip
}