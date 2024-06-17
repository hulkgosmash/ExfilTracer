resource "aws_instance" "ExfilTracer" {
    ami             = var.AMI
    instance_type   = var.Instance_type
    key_name = var.Key_name
    depends_on = [aws_security_group.ExfilTracer]
    security_groups = ["ExfilTracer${var.ClientID}"]
    connection {
        host = aws_instance.ExfilTracer.public_ip
        type = "ssh"
        user = "ubuntu"
        private_key = file(var.Private_key)
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
        Name        = "ExfilTracer_${var.ClientID}"
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
    egress {
        from_port = 0
        protocol = "-1"
        to_port = 0
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_route53_record" "ExfilTracer" {
    zone_id = var.Zone_id
    name    = "exfiltracer${var.ClientID}.${var.Root_domain}"
    type    = "A"
    ttl     = "300"
    records = [aws_instance.ExfilTracer.public_ip]
    depends_on = [aws_instance.ExfilTracer]
}