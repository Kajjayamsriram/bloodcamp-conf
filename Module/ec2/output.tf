output "inst_id" {
    value = {
    for name, inst in aws_instance.inst1 :
    name => inst.id
  }
}