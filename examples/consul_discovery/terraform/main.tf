data "aws_subnet" "selected" {
  id = "${var.subnet_id}"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_security_group" "rabbitmq" {
  vpc_id      = "${data.aws_subnet.selected.vpc_id}"
  name_prefix = "rabbitmq-ansible-example"
  description = "Rabbitmq Ansible role example"

  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "tcp"
    self      = true
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8500
    to_port     = 8500
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 15671
    to_port     = 15671
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

resource "aws_instance" "consul" {
  ami                    = "${data.aws_ami.ubuntu.id}"
  instance_type          = "t2.micro"
  key_name               = "${var.key_name}"
  subnet_id              = "${var.subnet_id}"
  vpc_security_group_ids = ["${aws_security_group.rabbitmq.id}"]

  tags {
    Name = "rabbitmq-example-consul"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${file("${var.private_key_path}")}"
  }

  provisioner "remote-exec" {
    inline = [
      "curl -fsSL https://get.docker.com -o get-docker.sh",
      "sudo sh get-docker.sh",
      "sudo docker run -d --name=consul --network=host --restart=always -e CONSUL_BIND_INTERFACE=eth0 consul agent -dev -client 0.0.0.0",
    ]
  }
}

resource "aws_instance" "rabbitmq" {
  count                  = 3
  ami                    = "${data.aws_ami.ubuntu.id}"
  instance_type          = "t2.micro"
  key_name               = "${var.key_name}"
  subnet_id              = "${var.subnet_id}"
  vpc_security_group_ids = ["${aws_security_group.rabbitmq.id}"]

  tags {
    Name = "rabbitmq-example-${count.index + 1}"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${file("${var.private_key_path}")}"
  }

  provisioner "remote-exec" {
    inline = [
      "curl -fsSL https://get.docker.com -o get-docker.sh",
      "sudo sh get-docker.sh",
      "sudo docker run -d --network=host --restart=always -e CONSUL_BIND_INTERFACE=eth0 consul agent -retry-join ${aws_instance.consul.private_ip}",
      "sudo apt-get install -y python",
    ]
  }

  provisioner "local-exec" {
    command = "ansible-playbook --diff -u ubuntu -i '${self.public_ip},' --private-key ${var.private_key_path} playbook.yml"
    environment = {
      ANSIBLE_CONFIG = "../../ansible.cfg"
    }
  }
}
