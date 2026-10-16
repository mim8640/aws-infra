# ============================================================
# Route53
# api.renuvo.store
# www.renuvo.store
# grafana.renuvo.store
# ============================================================

data "aws_route53_zone" "main" {
  zone_id = "Z0316600296I17AG9XGTH"
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
    "k8s-ingressn-ingressn-31d0dd916a-1761ea44704712ff.elb.ap-northeast-2.amazonaws.com"
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
    "k8s-ingressn-ingressn-31d0dd916a-1761ea44704712ff.elb.ap-northeast-2.amazonaws.com"
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
    "k8s-ingressn-ingressn-31d0dd916a-1761ea44704712ff.elb.ap-northeast-2.amazonaws.com"
  ]
}
