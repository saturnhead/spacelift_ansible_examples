variable "instances" {
  type = map(object({
    instance_type = optional(string, "t2.micro")
    tags          = optional(map(string), {})
  }))
  default = {
    instance1 = {
      tags = {"Env": "dev"}
    }
    instance2 = {
      tags = {"Env": "dev"}
    }
    instance3 = {
      tags = {"Env": "qa"}
    }
    instance4 = {
      tags = {"Env": "prod"}
    }
    instance5 = {
      tags = {"Env": "prod"}
    }
  }
}
