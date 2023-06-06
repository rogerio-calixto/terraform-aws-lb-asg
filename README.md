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
- asg-min
- subnet_counts -> this value is uset to create subnets for diferents AZ´s and for asg-max and asg-desired

## Example:

- region            -> "us-east-1"
- ami               -> "ami-0eae0940d45f46876"
- instance-type     -> "t3.micro"
- keypair-name      -> "devops-keypair"
- instance-name     -> "portfolio"
- authorized-ssh-ip -> "123.456.789.100"
- asg-min           -> 0
- subnet_counts     -> 3

# outputs

Some key fields about infrastructure created will be returned:

- instance_public_ip
- sg-id
- sg_lb-id
- avaiable_zones
- private-subnet-ids [] -> list(string)
- public-subnet-ids [] -> list(string)
- vpc-id
- load-balancer-dns

# TF commands

## Plan
terraform plan -out="tfplan.out"
## Apply
terraform apply "tfplan.out"
## Destroy
terraform destroy -auto-approve
