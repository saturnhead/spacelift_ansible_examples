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
        ansible_checkov = {
            repo             = "spacelift_ansible_examples"
            branch           = "main"
            project_root     = "infra_cfg/ansible_checkov" 
            description      = "Ansible stack that uses a dynamic inventory and scans for vulnerabilities"
            labels           = ["ansible", "ansible_checkov"]
            before_init      = ["aws ssm get-parameter --region eu-west-1 --name '/dev/ssh/private_key' --with-decryption --query 'Parameter.Value' --output text > /mnt/workspace/id_rsa_ansible",
                "python3 -m pip install boto3 --break-system-packages", 
                "chmod 600 /mnt/workspace/id_rsa_ansible",
                "python3 -m pip install checkov --break-system-packages",
                "export PATH=$PATH:/home/spacelift/.local/bin",
                "checkov -s -o json --directory . --framework ansible > checkov.custom.spacelift.json"
            ]
            before_apply     = ["python3 -m pip install boto3 --break-system-packages", "chmod 600 /mnt/workspace/id_rsa_ansible"]
            ansible_playbook = ["ansible_playbook.yaml"]
        }
    }
    policies = {
      checkov_scan_ansible = {
        policy_name        = "Checkov scan Ansible"
        policy_file_name   = "checkov_ansible"
        type               = "PLAN"
        labels             = ["autoattach:ansible_checkov"]
      }
    }
    integrations = {
      ansible_integration = {
        integration_id = "01H79TE7EP3W7K4AMMV447J189"
        stack_name     = "ansible_checkov"      
      }
    }
    contexts = {}
    env_vars = {
      ansible_cfg = {
        name           = "ANSIBLE_CONFIG"
        value          = "/mnt/workspace/source/infra_cfg/ansible_checkov/ansible.cfg"
        stack_name     = "ansible_checkov"
        add_to_context = false
      }
      skip_plan = {
        name           = "SPACELIFT_SKIP_PLANNING"
        value          = true
        stack_name     = "ansible_checkov"
        add_to_context = false
      }
    }
}