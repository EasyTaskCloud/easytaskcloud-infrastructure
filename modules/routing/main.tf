# -------------------------
# Elastic IPs für NATs
# -------------------------
resource "aws_eip" "nat" {
  count  = length(var.public_subnet_ids)
  domain = "vpc"
}

# -------------------------
# NAT Gateways (pro AZ)
# -------------------------
resource "aws_nat_gateway" "nat" {
  count         = length(var.public_subnet_ids)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = var.public_subnet_ids[count.index]

  tags = {
    Name = "easytaskcloud-nat-${count.index}"
  }
}

# -------------------------
# Public Route Table
# -------------------------
resource "aws_route_table" "public" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.igw_id
  }

  tags = {
    Name = "easytaskcloud-public-rtb"
  }
}

# Public Subnets zuordnen
resource "aws_route_table_association" "public_assoc" {
  count          = length(var.public_subnet_ids)
  subnet_id      = var.public_subnet_ids[count.index]
  route_table_id = aws_route_table.public.id
}

# -------------------------
# Private Route Tables (pro NAT)
# -------------------------
resource "aws_route_table" "private" {
  count  = length(var.private_subnet_ids)
  vpc_id = var.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[count.index].id
  }

  tags = {
    Name = "easytaskcloud-private-rt-${count.index}"
  }
}

# Private Subnets zuordnen
resource "aws_route_table_association" "private_assoc" {
  count          = length(var.private_subnet_ids)
  subnet_id      = var.private_subnet_ids[count.index]
  route_table_id = aws_route_table.private[count.index].id
}