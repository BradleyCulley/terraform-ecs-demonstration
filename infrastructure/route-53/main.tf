variable "frontend_alb_dns_name" {
  type = string
}

variable "backend_alb_dns_name" {
  type = string
}

variable "alb_zone_id" {
  type = string
}

variable "domain_name" {
  type = string
}

data "aws_route53_zone" "selected" {
  zone_id = "Z07038773K008E62F0OGT"
  private_zone = false
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = var.frontend_alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "backend" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "server.${var.domain_name}"
  type    = "A"

  alias {
    name                   = var.backend_alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}

resource "aws_acm_certificate" "acm_certificate" {
  domain_name               = var.domain_name
  // can uncomment this if subdomains are wanted later on
  subject_alternative_names = ["*.${var.domain_name}"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "validation_record" {
  for_each = {
    for dvo in aws_acm_certificate.acm_certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60 # TODO set to 24 hours (86400) once this configuration is all set
  type            = each.value.type
  zone_id         = data.aws_route53_zone.selected.zone_id
}

resource "aws_acm_certificate_validation" "certificate_validation" {
  certificate_arn         = aws_acm_certificate.acm_certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.validation_record : record.fqdn]
}

output "acm_certificate_arn" {
  value = aws_acm_certificate_validation.certificate_validation.certificate_arn
}
