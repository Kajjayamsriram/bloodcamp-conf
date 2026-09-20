output "ecr_repo" {
    value = {
        for name, repo in aws_ecr_repository.registry1 :
        name => repo.name
    }
}