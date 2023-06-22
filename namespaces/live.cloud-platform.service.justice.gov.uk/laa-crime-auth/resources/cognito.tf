resource "aws_cognito_user_pool" "evidence_user_pool" {
  name = var.user_pool_name_evidence

  account_recovery_setting {
    recovery_mechanism {
      name     = "admin_only"
      priority = 1
    }
  }
}

resource "aws_cognito_user_pool_domain" "evidence_domain" {
  domain       = var.cognito_user_pool_domain_name_evidence
  user_pool_id = aws_cognito_user_pool.evidence_user_pool.id
}

resource "aws_cognito_user_pool" "hardship_user_pool" {
  name = var.user_pool_name_hardship

  account_recovery_setting {
    recovery_mechanism {
      name     = "admin_only"
      priority = 1
    }
  }
}

resource "aws_cognito_user_pool_domain" "hardship_domain" {
  domain       = var.cognito_user_pool_domain_name_hardship
  user_pool_id = aws_cognito_user_pool.hardship_user_pool.id
}
