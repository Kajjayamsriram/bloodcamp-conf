output "sg"{
    value = {
        for name, sg in aws_security_group.sg :
        name => sg.id
    }
}