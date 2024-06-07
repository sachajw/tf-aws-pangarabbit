# Create IAM Role for RDS
resource "aws_iam_role" "rds_s3_integration" {
  name = "rds-s3-integration-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "rds.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "RDSS3IntegrationRole"
  }
}

# Attach Policy to the IAM Role
resource "aws_iam_role_policy" "rds_s3_policy" {
  name = "rds-s3-policy"
  role = aws_iam_role.rds_s3_integration.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject"
        ],
        Effect   = "Allow",
        Resource = [
          "arn:aws:s3:::your-bucket-name",
          "arn:aws:s3:::your-bucket-name/*"
        ]
      }
    ]
  })
}

# Attach IAM Role to RDS (Add to existing RDS configuration)
resource "aws_db_instance" "main" {
  # existing RDS resource block here

  iam_database_authentication_enabled = true
  db_subnet_group_name                = aws_db_subnet_group.main.name
  vpc_security_group_ids              = [aws_security_group.main.id]
  # additional required fields

  depends_on = [aws_iam_role_policy.rds_s3_policy]
}
