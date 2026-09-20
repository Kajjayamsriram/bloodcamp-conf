resource "aws_ecr_repository" "registry1" {
    for_each = var.repos
    name = each.key
    image_tag_mutability = each.value.mutability
    encryption_configuration {
        encryption_type = each.value.encrypt
    }
}
resource "aws_ecr_lifecycle_policy" "ecr_policy"{
    for_each = var.repos
    repository = aws_ecr_repository.registry1[each.key].name
    policy = jsonencode({
    rules = [
        {
        "rulePriority": 1,
        "description": "delete images older then 30 versions",
        "selection": {
            "tagStatus": "tagged",
            "tagPrefixList": [
            "v"
            ],
            "countType": "imageCountMoreThan",
            "countNumber": 30
        }
        "action": {
            "type": "expire"
        }
        },
        {
        "rulePriority": 2,
        "description": "delete images without tags older to 7 days",
        "selection": {
            "tagStatus": "untagged",
            "countType": "sinceImagePushed",
            "countUnit": "days",
            "countNumber": 7
        }
        "action": {
            "type": "expire"
        }
        }
    ]
    })
}