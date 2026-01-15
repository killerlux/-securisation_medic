resource "aws_db_instance" "main" {
  identifier = "${var.project_name}-${var.environment}-db"

  engine         = "postgres"
  engine_version = "15.4" # Use a supported version compliant with requirements
  instance_class = var.instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true
  kms_key_id            = var.kms_key_arn

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password # In production, use Secrets Manager, but for this module variable is passed (assume from secrets)

  multi_az               = var.multi_az
  publicly_accessible    = false
  vpc_security_group_ids = var.vpc_security_group_ids
  db_subnet_group_name   = var.db_subnet_group_name

  # Performance Insights with Encryption
  performance_insights_enabled          = true
  performance_insights_kms_key_id       = var.kms_key_arn
  performance_insights_retention_period = 7 # 7 days free tier, or higher for compliance

  # Backup & Maintenance
  backup_retention_period = 35 # HIPAA often requires long retention
  backup_window           = "03:00-04:00"
  maintenance_window      = "Mon:04:00-Mon:05:00"
  copy_tags_to_snapshot   = true
  deletion_protection     = true
  skip_final_snapshot     = false
  final_snapshot_identifier = "${var.project_name}-${var.environment}-final-snapshot"

  # Logging
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  parameter_group_name = aws_db_parameter_group.main.name

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-${var.environment}-db"
      Compliance  = "HIPAA"
      Environment = var.environment
    }
  )
}

resource "aws_db_parameter_group" "main" {
  name        = "${var.project_name}-${var.environment}-pg"
  family      = "postgres15"
  description = "Custom parameter group for secure RDS"

  # Force SSL for all connections (Compliance)
  parameter {
    name  = "rds.force_ssl"
    value = "1"
  }

  # Auditing (pgaudit) configuration would go here if using custom option groups/extensions
  # This is a parameter group, pgaudit requires shared_preload_libraries in parameter group
  parameter {
    name  = "shared_preload_libraries"
    value = "pgaudit"
    apply_method = "pending-reboot"
  }
  
  parameter {
    name  = "pgaudit.log"
    value = "write, ddl, role" # Log writes, schema changes, and role changes
  }

  tags = var.tags
}

# Variables
variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.medium"
}

variable "allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Max allocated storage for autoscaling"
  type        = number
  default     = 100
}

variable "kms_key_arn" {
  description = "KMS Key ARN for encryption"
  type        = string
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_username" {
  description = "Database master username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database master password"
  type        = string
  sensitive   = true
}

variable "multi_az" {
  description = "Enable Multi-AZ"
  type        = bool
  default     = true
}

variable "vpc_security_group_ids" {
  description = "List of VPC security group IDs"
  type        = list(string)
}

variable "db_subnet_group_name" {
  description = "DB Subnet Group Name"
  type        = string
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}

output "db_instance_endpoint" {
  description = "The connection endpoint"
  value       = aws_db_instance.main.endpoint
}

output "db_instance_arn" {
  description = "The ARN of the RDS instance"
  value       = aws_db_instance.main.arn
}

