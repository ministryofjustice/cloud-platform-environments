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


resource "aws_cognito_user_pool" "cma_user_pool" {
  name = var.user_pool_name_cma

  account_recovery_setting {
    recovery_mechanism {
      name     = "admin_only"
      priority = 1
    }
  }
}

resource "aws_cognito_user_pool_domain" "cma_domain" {
  domain       = var.cognito_user_pool_domain_name_cma
  user_pool_id = aws_cognito_user_pool.cma_user_pool.id
}

resource "aws_cognito_user_pool" "ccp_user_pool" {
  name = var.user_pool_name_ccp

  account_recovery_setting {
    recovery_mechanism {
      name     = "admin_only"
      priority = 1
    }
  }
}

resource "aws_cognito_user_pool_domain" "ccp_domain" {
  domain       = var.cognito_user_pool_domain_name_ccp
  user_pool_id = aws_cognito_user_pool.ccp_user_pool.id
}

