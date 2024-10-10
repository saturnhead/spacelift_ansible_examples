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
                "aws ssm get-parameter --region eu-west-1 --name '/ak/ssh/private_key' --with-decryption --query 'Parameter.Value' --output text > /mnt/workspace/id_rsa_ansible",
                "python3 -m pip install boto3 --break-system-packages", 
                "chmod 600 /mnt/workspace/id_rsa_ansible"
            ]
            before_apply     = ["python3 -m pip install boto3 --break-system-packages", "chmod 600 /mnt/workspace/id_rsa_ansible"]
            ansible_playbook = ["disk_threshold.yaml"]
        }
        opentofu_ak_parent = {
            repo                    = "spacelift_ansible_examples"
            branch                  = "main"
            project_root            = "infra_cfg/opentofu_dependency" 
            description             = "OpenTofu stack that creates ec2 instances"
            labels                  = ["opentofu"]
            terraform_workflow_tool = "OPEN_TOFU"
        }
        k8s_opentofu_config = {
            repo                    = "spacelift_ansible_examples"
            branch                  = "main"
            project_root            = "infra_cfg/kubernetes" 
            description             = "K8s stack that deploys nginx inside a cluster"
            labels                  = ["opentofu"]
            kubernetes_namespace    = "nginx" 
            before_init             = ["$EKS_LOGIN"]
        }
    }
    integrations = {
      ansible_integration = {
        integration_id = var.integration_id
        stack_name     = "ansible_opentofu_inventory"      
      }
      opentofu_integration = {
        integration_id = var.integration_id
        stack_name     = "opentofu_ak_parent"
      }
      k8s_integration = {
        integration_id = var.integration_id
        stack_name     = "k8s_opentofu_config"
      }
    }
    contexts = {}
    env_vars = {
      ansible_cfg = {
        name           = "ANSIBLE_CONFIG"
        value          = "/mnt/workspace/source/infra_cfg/ansible_dependency/ansible.cfg"
        stack_name     = "ansible_opentofu_inventory"
        add_to_context = false
      }
    }
    stack_dependencies = {
        opentofu_ansible = {
            stack_parent = "opentofu_ak_parent"
            stack_child  = "ansible_opentofu_inventory"
        }
        opentofu_k8s = {
            stack_parent = "opentofu_ak_parent"
            stack_child  = "k8s_opentofu_config"
        }
    }
    dependency_variables = {
      ansible_opentofu = {
        dependency_name = "opentofu_ansible"
        output_name     = "instance_info"
        input_name      = "INSTANCE_JSON"
      }
      kubernetes_opentofu = {
        dependency_name = "opentofu_k8s"
        output_name     = "eks_connect"
        input_name      = "EKS_LOGIN"
      }
    }
}