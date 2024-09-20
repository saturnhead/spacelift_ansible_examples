resource "spacelift_stack" "this" {
  for_each                = var.stacks
  branch                  = each.value.branch
  description             = each.value.description
  name                    = each.key
  project_root            = each.value.project_root
  repository              = each.value.repo
  terraform_workflow_tool = each.value.terraform_workflow_tool
  terraform_version       = each.value.version
  labels                  = each.value.labels
  space_id                = each.value.space_name
  runner_image            = each.value.runner_image
  worker_pool_id          = each.value.worker_pool_id
  before_init             = each.value.before_init
  before_plan             = each.value.before_plan
  before_apply            = each.value.before_apply
  
  dynamic "ansible" {
    for_each = each.value.ansible_playbook
    content {
        playbook = ansible.value
    }
  }
}

resource "spacelift_aws_integration_attachment" "integration" {
  for_each       = var.integrations
  integration_id = each.value.integration_id
  stack_id       = spacelift_stack.this[each.value.stack_name].id
  read           = each.value.read
  write          = each.value.write
}

resource "spacelift_context" "this" {
  for_each     = var.contexts
  description  = each.value.description
  name         = each.key
  before_init  = each.value.before_init
  before_plan  = each.value.before_plan
  before_apply = each.value.before_apply
  space_id     = each.value.space_name
  labels       = each.value.labels
}


resource "spacelift_policy" "this" {
  for_each = var.policies
  name     = each.value.policy_name
  body     = file("${path.module}/policies/${each.value.policy_file_name}.rego")
  type     = each.value.type
  #labels   = [for label in each.value.labels: "autoattach:${label}"]
  labels   = each.value.labels
}

resource "spacelift_environment_variable" "this" {
  for_each   = var.env_vars
  context_id = each.value.add_to_context ? spacelift_context.this[each.value.context_name].id : null
  stack_id   = each.value.add_to_context ? null : spacelift_stack.this[each.value.stack_name].id
  name       = each.value.name
  value      = each.value.value
  write_only = each.value.is_secret
}

resource "tls_private_key" "rsa" {
  for_each      = {for context_key, context_value in var.contexts: context_key => context_value if context_value.add_public_ssh_key == true }
  algorithm     = "RSA"
  rsa_bits      = 4096
}

resource "spacelift_mounted_file" "public_ssh_key" {
  for_each      = {for context_key, context_value in var.contexts: context_key => context_value if context_value.add_public_ssh_key == true }
  context_id    = spacelift_context.this[each.key].id
  relative_path = "id_rsa.pub"
  content       = base64encode(tls_private_key.rsa[each.key].public_key_openssh)
}

resource "spacelift_mounted_file" "private_ssh_key" {
  for_each      = {for context_key, context_value in var.contexts: context_key => context_value if context_value.add_private_ssh_key == true }
  context_id    = spacelift_context.this[each.key].id
  relative_path = "id_rsa"
  content       = base64encode(tls_private_key.rsa[each.key].private_key_openssh)
}

resource "spacelift_mounted_file" "this" {
  for_each      = var.mounted_files
  context_id    = spacelift_context.this[each.value.context_name].id
  relative_path = each.value.relative_path
  content       = filebase64(each.value.content)
}

resource "spacelift_context_attachment" "this" {
  for_each   = var.context_attachments
  context_id = spacelift_context.this[each.value.context_name].id
  stack_id   = spacelift_stack.this[each.value.stack_name].id
  priority   = each.value.priority
}