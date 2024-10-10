output "instance_info" {
  value = jsonencode({ 
    for name, instance in aws_instance.this : name => {
      env        = lookup(instance.tags, "Env", "other")
      public_dns = instance.public_dns
    }
  })
}

output "eks_connect" {
  value = "aws eks --region eu-west-1 update-kubeconfig --name ${aws_eks_cluster.main.name}"
}