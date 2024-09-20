# Spacelift Ansible examples

You can find all examples in the examples directory.

## Ansible with dynamic inventory

This will run a playbook that install nginx on all of your hosts, only if the free disk space is greater than 10.0GB.

The inventory is build using AWS Dynamic inventory and it will just use the instances with the Env: dev tags, from the eu-west-1 region that are in a running state:

```yaml
plugin: aws_ec2
regions:
  - eu-west-1
filters:
  tag:Env: dev
  instance-state-name: running
```

To override runtime configuration for the free disk space threshold, you can use this:

```yaml
environment:
  SPACELIFT_ANSIBLE_CLI_ARGS: -e disk_space_threshold=2.0
```
