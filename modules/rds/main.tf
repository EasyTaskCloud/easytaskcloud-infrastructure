# -------------------------
# DB Subnet Group
# -------------------------
resource "aws_db_subnet_group" "db_subnets" {
  name       = "${var.project_name}-db-subnets"
  subnet_ids = var.private_subnet_ids

  tags = { Name = "${var.project_name}-db-subnets" }
}

# -------------------------
# RDS PostgreSQL Instance
# -------------------------
resource "aws_db_instance" "postgres" {
  identifier              = "${var.project_name}-db"
  engine                  = "postgres"
  engine_version          = "17.2"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  max_allocated_storage   = 100
  db_subnet_group_name    = aws_db_subnet_group.db_subnets.name
  vpc_security_group_ids  = [var.db_sg_id]
  publicly_accessible     = false
  multi_az                = false
  storage_encrypted       = true
  backup_retention_period = 7
  skip_final_snapshot     = true

  db_name     = "easytaskdb"
  username = "sebi"
  password = "SuperSecurePass123!" # 🔑 in Prod besser über Secrets Manager

  tags = { Name = "${var.project_name}-db" }
}
