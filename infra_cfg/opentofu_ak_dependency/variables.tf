variable "instances" {
  type = map(object({
    instance_type = optional(string, "t2.micro")
    tags          = optional(map(string), {})
  }))
  default = {
    instancedev1 = {
      tags = {"Env": "dev"}
    }
    instanceqa2 = {
      tags = {"Env": "qa"}
    }
    instanceqa3 = {
      tags = {"Env": "qa"}
    }
  }
}