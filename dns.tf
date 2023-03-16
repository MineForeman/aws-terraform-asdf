
/*
# Create DNS records for the instances
resource "aws_route53_record" "a_nrf_asdf_co_nz" {
  zone_id = var.route53_zone_id
  name    = "nrf.${var.route53_domain_name}"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.devops-instance.public_ip]
}

resource "aws_route53_record" "a_psql_asdf_co_nz" {
  zone_id = var.route53_zone_id
  name    = "psql.${var.route53_domain_name}"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.pervasive-instance.public_ip]
}

*/
resource "aws_route53_record" "a_win_asdf_co_nz" {
  zone_id = var.route53_zone_id
  name    = "win.${var.route53_domain_name}"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.windows-instance.public_ip]
}



