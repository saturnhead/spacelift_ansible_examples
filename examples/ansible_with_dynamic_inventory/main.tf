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
            labels           = ["ansibleDev"]
        }
    }
    integrations = {
      ansible_integration = {
        integration_id = var.integration_id
        stack_name     = "ansible_dynamic_inventory"      
      }
    }
    contexts = {
      ansible_context = {
        description         = "Ansible context"
        labels              = ["autoattach:ansibleDev"]
        before_init         = ["python3 -m pip install boto3 --break-system-packages", "aws ssm get-parameter --region eu-west-1 --name '/ec2_standalone/ssh/private_key' --with-decryption --query 'Parameter.Value' --output text > /mnt/workspace/id_rsa_ansible", "chmod 600 /mnt/workspace/id_rsa_ansible"]
        before_apply        = ["python3 -m pip install boto3 --break-system-packages", "chmod 600 /mnt/workspace/id_rsa_ansible"]
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
