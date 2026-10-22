# ============================================================
# Route53
# api.wecnedu.com
# www.wecnedu.com
# grafana.wecnedu.com
# ============================================================

data "aws_route53_zone" "main" {
  zone_id = "Z0316600296I17AG9XGTH"
}

# ------------------------------------------------------------
# Current Kubernetes Public ALB
# ------------------------------------------------------------
locals {
  public_alb_dns = " k8s-ingressn-ingressn-7791990f4f-4f346a245a40be30.elb.ap-northeast-2.amazonaws.com"
}

# ------------------------------------------------------------
# API
# ------------------------------------------------------------
resource "aws_route53_record" "api" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "api.renuvo.store"
  type    = "CNAME"
  ttl     = 300

  records = [
    local.public_alb_dns
  ]
}

# ------------------------------------------------------------
# Frontend
# ------------------------------------------------------------
resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "www.renuvo.store"
  type    = "CNAME"
  ttl     = 300

  records = [
    local.public_alb_dns
  ]
}

# ------------------------------------------------------------
# Grafana
# ------------------------------------------------------------
resource "aws_route53_record" "grafana" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "grafana.renuvo.store"
  type    = "CNAME"
  ttl     = 300

  records = [
    local.public_alb_dns
  ]
}
