output "private_vm_private_ip" {
  value = aws_instance.private_vm.private_ip
}

output "public_vm_public_ip" {
  value = aws_instance.public_vm.public_ip
}
