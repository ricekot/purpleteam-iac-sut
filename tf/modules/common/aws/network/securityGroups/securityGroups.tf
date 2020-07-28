// Adopt defaults

resource "aws_default_security_group" "default_vpc" {
  vpc_id = var.vpc_id_default
  tags = {
    Name = "Default security group from default vpc"
  }
}

resource "aws_default_security_group" "cust_vpc" {
  vpc_id = var.vpc_id
  tags = {
    Name = "Default security group from default vpc: ${var.non_default_vpc_name}"
  }
}

// We used to have security groups which reference each other, we had to use external rules rather than inline.
// Inline vs external: http://cavaliercoder.com/blog/inline-vs-discrete-security-groups-in-terraform.html
// Todo: Kim C: Refactor to use aws_security_group_rules, when it's merged.
// Now that we're using NLB rather than ALB we could actually put them inline again, but we may as well wait and use the aws_security_group_rules when it's ready.
//   Details:
//   * https://github.com/terraform-providers/terraform-provider-aws/pull/1824
//   * https://github.com/terraform-providers/terraform-provider-aws/pull/9032 

// SSH access list

resource "aws_security_group" "ssh_access_list" {  
  vpc_id       = var.vpc_id
  name         = "SSH access list"
  description  = "Allows SSH from specific users to instances within the VPC"

  tags = {
    Name = "SSH-access-list"
    source = "iac-nw-securityGroups"
  }
}

resource "aws_security_group_rule" "ssh_access_list" {
  for_each = toset(keys(var.admin_source_ips))

  type = "ingress"
  protocol = "tcp"
  from_port   = 22
  to_port     = 22
  description = var.admin_source_ips[each.key].description
  cidr_blocks = var.admin_source_ips[each.key].source_ips
  security_group_id = aws_security_group.ssh_access_list.id
}

// https://github.com/hashicorp/terraform/issues/1313#issuecomment-107619807
// https://www.iana.org/assignments/icmp-parameters/icmp-parameters.xhtml
resource "aws_security_group_rule" "icmp" {
  for_each = toset(keys(var.admin_source_ips))
  
  type = "ingress"
  protocol = "icmp"
  from_port   = 8
  to_port     = 0
  description = var.admin_source_ips[each.key].description
  cidr_blocks = var.admin_source_ips[each.key].source_ips
  security_group_id = aws_security_group.ssh_access_list.id
}

// purpleteam

resource "aws_security_group" "purpleteam" {
  vpc_id       = var.vpc_id
  name         = "purpleteam"
  description  = "NLB to SUT security group"

  tags = {
    Name = "purpleteam"
    source = "iac-nw-securityGroups"
  }
}

resource "aws_security_group_rule" "purpleteam_ingress_from_nlb_for_health_check" {
  description = "ingress from NLB for health check and purpleteam requests"
  type = "ingress"
  protocol = "tcp"
  from_port = 2000
  to_port = 2000
  security_group_id = aws_security_group.purpleteam.id
  cidr_blocks = var.aws_nlb_ips
}
