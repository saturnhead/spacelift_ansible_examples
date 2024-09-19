output "stacks" {
    value = {for stack_key, stack_value in spacelift_stack.this: stack_key => {"name": stack_value.name, "space_id": stack_value.space_id}}
}