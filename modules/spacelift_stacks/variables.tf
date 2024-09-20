variable "stacks" {
  description = "A map of stack configurations"
  type = map(object({
    branch                  = string
    description             = string
    project_root            = string
    repo                    = string
    terraform_workflow_tool = optional(string, null)
    version                 = optional(string, null)
    labels                  = optional(list(string), [])
    space_name              = optional(string, "root")
    runner_image            = optional(string, null)
    worker_pool_id          = optional(string, null)
    ansible_playbook        = optional(set(string), [])
    before_init             = optional(list(string), [])
    before_plan             = optional(list(string), [])
    before_apply            = optional(list(string), [])
  }))
}

variable "integrations" {
  description = "A map of integration configurations"
  type = map(object({
    integration_id = string
    stack_name     = string
    read           = optional(bool, true)
    write          = optional(bool, true)
  }))
  default = {}
}

variable "contexts" {
  description = "A map of context configurations"
  type = map(object({
    description         = string
    before_init         = optional(list(string), [])
    before_plan         = optional(list(string), [])
    before_apply        = optional(list(string), [])
    space_name          = optional(string, "root")
    add_public_ssh_key  = optional(bool, "false")
    add_private_ssh_key = optional(bool, "false")
    labels              = optional(list(string), null)
  }))
  default = {}
}

variable "env_vars" {
  description = "A map of environment variable configurations"
  type = map(object({
    context_name   = optional(string, null)
    stack_name     = optional(string, null)
    add_to_context = optional(bool, true)
    name           = string
    value          = string
    is_secret      = optional(bool, false)
  }))
  default = {}
}

variable "mounted_files" {
  description = "A map of mounted files that will be added to a context"
  type = map(object({
    context_name  = string
    relative_path = string
    content       = string
  })) 
  default = {}
}

variable "context_attachments" {
  description = "A map of context attachment configurations"
  type = map(object({
    context_name = string
    stack_name   = string
    priority     = optional(number, 0)
  }))
  default = {}
}


variable "policies" {
  description = "A map of policies, that should have the autoattach:label added"
  type = map(object({
    policy_name      = string # "Display name of the policy"
    policy_file_name = string # "Name of the policy file, withouth the .rego extenstion" 
    type             = string # Policy type, can be PLAN, APPROVAL, GIT_PUSH, NOTIFICATION, TRIGGER
    labels           = list(string) # A list of labels, for autoattaching, add the autoattach:label
  }))
  default = {}
}