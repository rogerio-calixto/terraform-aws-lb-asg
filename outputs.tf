output "sg-id" {
  value = aws_security_group.sg.id
}

output "sg_lb-id" {
  value = aws_security_group.sg-lb.id
}

output "vpc-id" {
  value = module.network.vpc-id
}

output "avaiable_zones" {
  value = module.network.avaiable_zones
}

output "private-subnet-ids" {
  value = module.network.private-subnet-ids
}

output "public-subnet-ids" {
  value = module.network.public-subnet-ids
}

output "lb-dns" {
  value = aws_alb.load_balancer.dns_name
}