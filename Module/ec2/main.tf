data "aws_key_pair" "key"{
    key_name = "nasa"
}
resource "aws_instance" "inst1" {
  for_each = var.instances
  tags = var.tags
  instance_type = each.value.itype
  key_name = data.aws_key_pair.key.key_name
  ami = each.value.ami
  subnet_id = each.value.subnet_id
  vpc_security_group_ids =  [ each.value.sg ]
  root_block_device {
    volume_size = each.value.vol_size
  }
  iam_instance_profile = each.value.inst_profile
  user_data = var.udata
}