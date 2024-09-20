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
        ansible_opentofu_inventory = {
            repo             = "spacelift_ansible_examples"
            branch           = "main"
            project_root     = "infra_cfg/ansible_dependency" 
            description      = "Ansible stack that uses an OpenTofu generated inventory"
            labels           = ["ansible"]
            before_init      = ["echo \"$INSTANCE_JSON\" | jq -r 'to_entries | group_by(.value.env) | .[] as $group | \"[\" + $group[0].value.env + \"]\\n\" + ($group | map(.value.public_dns) | join(\"\\n\")) + \"\\n\"' > /mnt/workspace/ansible_inventory.ini", 
                "python3 -m pip install boto3 --break-system-packages", 
                "chmod 600 /mnt/workspace/id_rsa"
            ]
            before_apply     = ["python3 -m pip install boto3 --break-system-packages", "chmod 600 /mnt/workspace/id_rsa"]
            ansible_playbook = ["disk_threshold.yaml"]
        }
        opentofu_ansible_parent = {
            repo             = "spacelift_ansible_examples"
            branch           = "main"
            project_root     = "infra_cfg/opentofu_dependency" 
            description      = "OpenTofu stack that creates ec2 instances"
            labels           = ["opentofu"]
        }
    }
    integrations = {
      ansible_integration = {
        integration_id = "01H79TE7EP3W7K4AMMV447J189"
        stack_name     = "ansible_opentofu_inventory"      
      }
      opentofu_integration = {
        integration_id = "01H79TE7EP3W7K4AMMV447J189"
        stack_name     = "opentofu_ansible_parent"
      }
    }
    contexts = {}
    env_vars = {
      ansible_cfg = {
        name           = "ANSIBLE_CONFIG"
        value          = "/mnt/workspace/source/infra_cfg/ansible_dependency/ansible.cfg"
        stack_name     = "ansible_context"
        add_to_context = false
      }
    }
    stack_dependencies = {
        opentofu_ansible = {
            stack_parent = "opentofu_ansible_parent"
            stack_child  = "ansible_opentofu_inventory"
        }
    }
    dependency_variables = {
      var1 = {
        dependency_name = "opentofu_ansible"
        output_name     = "instance_info"
        input_name      = "INSTANCE_JSON"
      }
    }
}