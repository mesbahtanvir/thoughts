# Web Application Firewall (WAF) for CloudFront
resource "aws_wafv2_web_acl" "frontend" {
  name        = "${var.app_name}-${var.environment}-waf"
  description = "WAF Web ACL for ${var.app_name} frontend"
  scope       = "CLOUDFRONT"

  default_action {
    allow {}
  }


  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      none {}
    }


    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }


    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesCommonRuleSet"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.app_name}-${var.environment}-waf-metrics"
    sampled_requests_enabled   = true
  }

  tags = {
    Name        = "${var.app_name}-${var.environment}-waf"
    Environment = var.environment
  }
}
