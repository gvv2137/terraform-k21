resource "aws_instance" "k21-task" {
  ami           = "ami-0bcf5425cdc1d8a85"
  instance_type = "t2.micro"
  key_name = "terraform-key"
  security_groups = ["${aws_security_group.task-sg.name}"]
  associate_public_ip_address = true

tags = {
    Name = "k21 Instance"
  }


provisioner "local-exec" {
    command = "echo ${aws_instance.k21-task.public_ip} >> xyz.txt"
  }


provisioner "remote-exec" {
    inline = [
      "sudo amazon-linux-extras enable nginx1.12",
      "sudo yum -y install nginx",
      "sudo systemctl start nginx",
    ]
  }
  connection {
    type     = "ssh"
    user     = "ec2-user"
    host = self.public_ip
    private_key = file(var.ssh_priv_key)
  }

}

resource "aws_security_group" "task-sg" {
  name        = "task-sg"
  description = "Allow ssh traffic"


  ingress {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}
