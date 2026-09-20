variable "repos" {
    type = map(object({
        mutability = string
        encrypt = string
    }))
}