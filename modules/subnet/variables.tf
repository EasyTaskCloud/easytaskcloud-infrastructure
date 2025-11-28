variable "vpc_id" {}
variable "public_subnets" {
  type = map(string)
}

variable "private_subnets" {
  type = map(string)
}
