# terraform-aws-ec2
Creates an environment available and scalable

# Instruction:

Set the variables below according to your needs:

- region
- ami
- instance-type
- keypair-name
- instance-name
- authorized-ssh-ip -> [ For security don´t set it in variable default. Instead inform on terraform plan command ]

## Example:

- region            -> "us-east-1"
- ami               -> "ami-0715c1897453cabd1"
- instance-type     -> "t3.micro"
- keypair-name      -> "devops-keypair"
- instance-name     -> "devops-portfolio-instance"
- authorized-ssh-ip -> "123.456.789.100"

# outputs

Some key fields about infrastructure created will be returned:

- instance_public_ip
- main-sg-id
- private-avaiable_zone
- private-subnet-ids [] -> list(string)
- vpc-id
- load-balancer-dns

# TF commands

## Plan
terraform plan -out="tfplan.out"
## Apply
terraform apply "tfplan.out"
## Destroy
terraform destroy -auto-approve
