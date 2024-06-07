# Create RDS Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "main-subnet-group"
  subnet_ids = [aws_subnet.private.id]

  tags = {
    Name = "MainSubnetGroup"
  }
}

# Create RDS Instance for PostgreSQL
resource "aws_db_instance" "main" {
  allocated_storage       = 20
  max_allocated_storage   = 50 # Automatically scale up storage up to this limit
  engine                  = "postgres"
  engine_version          = "14.5" # Replace with the desired PostgreSQL version
  instance_class          = "db.t3.micro"
  name                    = "mydatabase"       # Optional: name of the database
  username                = "admin"            # Database username
  password                = "password"         # Database password (store securely in practice)
  db_subnet_group_name    = aws_db_subnet_group.main.name
  vpc_security_group_ids  = [aws_security_group.main.id]
  backup_window           = "03:00-06:00"      # Daily backup window
  backup_retention_period = 7                  # Retain backups for 7 days
  skip_final_snapshot     = true               # Don't create a final snapshot on deletion
  multi_az                = false              # Single availability zone deployment for cost efficiency
  storage_type            = "gp2"              # General Purpose SSD storage
  publicly_accessible     = false              # Ensure the RDS instance is not accessible publicly

  # Enable S3 Integration for PostgreSQL logs
  enabled_cloudwatch_logs_exports = ["postgresql"]

  tags = {
    Name = "MainPostgresRDSInstance"
  }

  # Optional: Add RDS IAM Role for S3 integration if needed
  iam_database_authentication_enabled = true
  depends_on = [aws_iam_role_policy.rds_s3_policy]
}
