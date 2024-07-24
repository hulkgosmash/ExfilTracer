data "aws_route53_zone" "selected" {
  name = var.Root_domain
}

data "local_file" "public_key" {
  filename = var.public_key_path
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]  # Canonical's AWS account ID
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = data.local_file.public_key.content
}

resource "aws_instance" "ExfilTracer" {
    ami             = data.aws_ami.ubuntu.id
    instance_type   = var.Instance_type
    key_name        = aws_key_pair.deployer.key_name
    depends_on      = [aws_security_group.ExfilTracer]
    security_groups = ["ExfilTracer${var.ClientID}"]
    connection {
        host = aws_instance.ExfilTracer.public_ip
        type = "ssh"
        user = "ubuntu"
        private_key = file(var.private_key_path)
    }
    provisioner "remote-exec" {
        inline = [
            "sleep 60",
            "sudo apt update",
            "sudo apt install ansible -y",
            "git clone https://github.com/hulkgosmash/ExfilTracer.git",
            "ansible-playbook ExfilTracer/ansible/main.yaml -e password='${var.Password}'",
        ]
    }
    tags                          = {
        Name        = "ExfilTracer${var.ClientID}"
        ClientID    = var.ClientID
    }
}

resource "aws_security_group" "ExfilTracer" {
    name = "ExfilTracer${var.ClientID}"
    tags                          = {
        Name        = "ExfilTracer${var.ClientID}"
        ClientID    = var.ClientID
    }
    ingress {
        from_port = 21
        to_port = 21
        protocol = "tcp"
        cidr_blocks = ["${var.IP_Address}"]
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 25
        to_port = 25
        protocol = "tcp"
        cidr_blocks = ["${var.IP_Address}"]
    }
    ingress {
        from_port = 53
        to_port = 53
        protocol = "udp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["${var.IP_Address}"]
    }
    ingress {
        from_port = 445
        to_port = 445
        protocol = "tcp"
        cidr_blocks = ["${var.IP_Address}"]
    }
    ingress {
        from_port = 3389
        to_port = 3389
        protocol = "tcp"
        cidr_blocks = ["${var.IP_Address}"]
    }
    ingress {
        from_port = 10000
        to_port = 10100
        protocol = "tcp"
        cidr_blocks = ["${var.IP_Address}"]
    }
    ingress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["${var.IP_Address}"]
    }
    egress {
        from_port = 0
        protocol = "-1"
        to_port = 0
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_route53_record" "ExfilTracer" {
    zone_id = data.aws_route53_zone.selected.zone_id
    name    = "exfiltracer${var.ClientID}.${var.Root_domain}"
    type    = "A"
    ttl     = "300"
    records = [aws_instance.ExfilTracer.public_ip]
    depends_on = [aws_instance.ExfilTracer]
}

resource "aws_route53_record" "dnsexfilns" {
    zone_id = data.aws_route53_zone.selected.zone_id
    name    = "ns.exfiltracer.${var.Root_domain}"
    type    = "NS"
    ttl     = "300"
    records = ["ns.exfiltracer${var.ClientID}.${var.Root_domain}"]
    depends_on = [aws_route53_record.ExfilTracer]
}