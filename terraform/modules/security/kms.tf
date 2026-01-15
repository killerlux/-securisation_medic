resource "aws_kms_key" "main" {
  description             = "Customer Managed Key for encrypting PHI and sensitive data"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  is_enabled              = true
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow access for Key Administrators"
        Effect = "Allow"
        Principal = {
          AWS = var.admin_roles
        }
        Action = [
          "kms:Create*",
          "kms:Describe*",
          "kms:Enable*",
          "kms:List*",
          "kms:Put*",
          "kms:Update*",
          "kms:Revoke*",
          "kms:Disable*",
          "kms:Get*",
          "kms:Delete*",
          "kms:TagResource",
          "kms:UntagResource",
          "kms:ScheduleKeyDeletion",
          "kms:CancelKeyDeletion"
        ]
        Resource = "*"
      },
      {
        Sid    = "Allow use of the key"
        Effect = "Allow"
        Principal = {
          AWS = var.user_roles
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name        = "kms-cmk-phi"
      Compliance  = "HIPAA"
      Environment = var.environment
    }
  )
}

resource "aws_kms_alias" "main" {
  name          = "alias/${var.environment}-phi-key"
  target_key_id = aws_kms_key.main.key_id
}

variable "account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "admin_roles" {
  description = "List of ARNs for Key Administrators"
  type        = list(string)
  default     = []
}

variable "user_roles" {
  description = "List of ARNs for Key Users (services/roles that need to encrypt/decrypt)"
  type        = list(string)
  default     = []
}

variable "environment" {
  description = "Deployment environment (e.g., dev, prod)"
  type        = string
}

variable "tags" {
  description = "Common tags for resources"
  type        = map(string)
  default     = {}
}

output "key_id" {
  description = "The globally unique identifier for the key"
  value       = aws_kms_key.main.key_id
}

output "key_arn" {
  description = "The Amazon Resource Name (ARN) of the key"
  value       = aws_kms_key.main.arn
}

