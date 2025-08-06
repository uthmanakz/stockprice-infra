resource "aws_security_group" "kubectl_sg" {
  name        = "kubectl-sg"
  description = "Allow SSH access"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Replace with your IP for better security
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "kubectl-sg"
  }
}

resource "aws_instance" "kubectl_machine" {
  ami           = "ami-071899a54a905868f" # Amazon Linux 2 (us-west-2); update if using another region
  instance_type = "t2.micro"

  subnet_id              = module.vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.kubectl_sg.id]
  associate_public_ip_address = true
  key_name               = "uthmanakz" # Replace with your EC2 key pair name

  tags = {
    Name = "kubectl-bastion"
  }
}