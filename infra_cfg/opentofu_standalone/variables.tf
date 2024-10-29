variable "instances" {
  type = map(object({
    instance_type = optional(string, "t2.micro")
    tags          = optional(map(string), {})
  }))
  default = {
    instance1 = {
      tags = {"Env": "devAnsible"}
    }
    instance2 = {
      tags = {"Env": "devAnsible"}
    }
    instance3 = {
      tags = {"Env": "devAnsible"}
    }
  }
}

variable "public_key" {
  type        = string
  description = "Path to the public ssh key"
  default     = "/mnt/workspace/id_rsa.pub"
}