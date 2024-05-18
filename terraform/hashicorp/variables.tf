variable "bucket_name" {
    type = string
    default = "silio-sync-bucket"
}

variable "ami_freetier" {
    type = map
    default = {
        "rhel" = "ami-00aa0673b34e3c150"
        "ubuntu" = "ami-830c94e3"
        "amazon-linux" = "ami-01acac09adf473073"
    }  
}

variable "aws_access_key" {
    default = env("aws_access_key")
}
variable "aws_secret_key" {
    default = env("aws_secret_key")
}