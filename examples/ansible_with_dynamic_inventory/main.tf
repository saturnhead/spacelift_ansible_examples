provider "spacelift" {}

terraform {
  required_providers {
    spacelift = {
      source = "spacelift-io/spacelift"
    }
  }
}

module "spacelift_stacks" {
    source = "../../modules/spacelift_stacks"
    stacks = {
        ansible_dynamic_inventory = {
            repo             = "spacelift_ansible_examples"
            branch           = "main"
            project_root     = "infra_cfg/ansible_dynamic_inventory" 
            description      = "Ansible stack that uses a dynamic AWS inventory"
            ansible_playbook = ["disk_threshold.yaml"]
            labels           = ["ansible"]
        }
    }
    integrations = {
      ansible_integration = {
        integration_id = "01H79TE7EP3W7K4AMMV447J189"
        stack_name     = "ansible_dynamic_inventory"      
      }
    }
    contexts = {
      ssh_key_context = {
        description         = "Ansible context"
        labels              = ["autoattach:ansible"]
        add_public_ssh_key  = true
        add_private_ssh_key = true
      }
      ansible_context = {
        description         = "Ansible context"
        labels              = ["autoattach:ansible"]
        before_init         = ["python3 -m pip install boto3 --break-system-packages", "chmod 600 /mnt/workspace/id_rsa"]
        before_apply        = ["python3 -m pip install boto3 --break-system-packages", "chmod 600 /mnt/workspace/id_rsa"]
      }
    }
    env_vars = {
      ansible_cfg = {
        name         = "ANSIBLE_CONFIG"
        value        = "/mnt/workspace/source/infra_cfg/ansible_dynamic_inventory/ansible.cfg"
        context_name = "ansible_context"
      }
    }
}