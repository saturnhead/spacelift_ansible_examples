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
    ansible_terraform_inventory = {
      repo         = "spacelift_ansible_examples"
      branch       = "main"
      project_root = "infra_cfg/ansible_dependency"
      description  = "Ansible stack that uses an terraform generated inventory"
      labels       = ["ansible", "ansibleTerraform"]
      before_init = ["echo \"$INSTANCE_JSON\" | jq -r 'to_entries | group_by(.value.env) | .[] as $group | \"[\" + $group[0].value.env + \"]\\n\" + ($group | map(.value.public_dns) | join(\"\\n\")) + \"\\n\"' > /mnt/workspace/ansible_inventory.ini",
        "aws ssm get-parameter --region eu-west-1 --name '/dev/ssh/private_key' --with-decryption --query 'Parameter.Value' --output text > /mnt/workspace/id_rsa_ansible",
        "python3 -m pip install boto3 --break-system-packages",
        "chmod 600 /mnt/workspace/id_rsa_ansible"
      ]
      before_apply     = ["python3 -m pip install boto3 --break-system-packages", "chmod 600 /mnt/workspace/id_rsa_ansible"]
      ansible_playbook = ["disk_threshold.yaml"]
    }
    terraform_ansible_parent = {
      repo         = "spacelift_ansible_examples"
      branch       = "main"
      project_root = "infra_cfg/terraform_dependency"
      description  = "terraform stack that creates ec2 instances"
      labels       = ["terraform", "ansibleTerraform"]
    }
  }
  integrations = {
    ansible_integration = {
      integration_id = var.integration_id
      stack_name     = "ansible_terraform_inventory"
    }
    terraform_integration = {
      integration_id = var.integration_id
      stack_name     = "terraform_ansible_parent"
    }
  }
  contexts = {}
  env_vars = {
    ansible_cfg = {
      name           = "ANSIBLE_CONFIG"
      value          = "/mnt/workspace/source/infra_cfg/ansible_dependency/ansible.cfg"
      stack_name     = "ansible_terraform_inventory"
      add_to_context = false
    }
  }
  stack_dependencies = {
    terraform_ansible = {
      stack_parent = "terraform_ansible_parent"
      stack_child  = "ansible_terraform_inventory"
    }
  }
  dependency_variables = {
    var1 = {
      dependency_name = "terraform_ansible"
      output_name     = "instance_info"
      input_name      = "INSTANCE_JSON"
    }
  }
}
