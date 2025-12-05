resource "aws_subnet" "public" {
  for_each          = var.public_subnets
  vpc_id            = var.vpc_id
  cidr_block        = each.value
  availability_zone = each.key
  map_public_ip_on_launch = true

  tags = {
    Name = "easytaskcloud-public-${each.key}"
  }
}

resource "aws_subnet" "privet" {
  for_each          = var.private_subnets
  vpc_id            = var.vpc_id
  cidr_block        = each.value
  availability_zone = each.key

  tags = {
    Name = "easytaskcloud-privet-${each.key}"
  }

}
