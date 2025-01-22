output "instance_info" {
  value = jsonencode({ 
    for name, instance in aws_instance.this : name => {
      env        = lookup(instance.tags, "Env", "other")
      public_dns = instance.public_dns
    }
  })
}