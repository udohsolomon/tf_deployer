resource "aws_instance" "WEB_A" {
    ami                         = lookup(var.aws_ubuntu_awis, var.region)
    instance_type               = "t2.micro"
    tags = {
        Name                    = "${var.environment}-WEB001"
        Environment             = "${var.environment}"
        sshUser                 = "ubuntu"
    }
    subnet_id                   = aws_subnet.public-web-az-a.id
    key_name                    = aws_key_pair.keypair.key_name
    vpc_security_group_ids      = ["${aws_security_group.WebserverSG.id}"]
}

resource "aws_instance" "WEB_B" {
    ami                         = lookup(var.aws_ubuntu_awis,var.region)
    instance_type               = "t2.micro"
    tags = {
        Name                    = "${var.environment}-WEB002"
        Environment             = "${var.environment}"
        sshUser                 = "ubuntu"
    }
    subnet_id                   = aws_subnet.public-web-az-b.id
    key_name                    = aws_key_pair.keypair.key_name
    vpc_security_group_ids      = ["${aws_security_group.WebserverSG.id}"]
}

resource "aws_instance" "BASTIONHOST_A" {
    ami                         = lookup(var.aws_ubuntu_awis,var.region)
    instance_type               = "t2.micro"
    tags = {
        Name                    = "${var.environment}-BASTION001"
        Environment             = "${var.environment}"
        sshUser                 = "ubuntu"
    }
    subnet_id                   = aws_subnet.public-web-az-a.id
    key_name                    = aws_key_pair.keypair.key_name
    vpc_security_group_ids      = ["${aws_security_group.bastionhostSG.id}"]
}

resource "aws_instance" "BASTIONHOST_B" {
    ami                         = lookup(var.aws_ubuntu_awis,var.region)
    instance_type               = "t2.micro"
    tags = {
        Name                    = "${var.environment}-BASTION002"
        Environment             = "${var.environment}"
        sshUser = "ubuntu"
    }
    subnet_id                   = aws_subnet.public-web-az-b.id
    key_name                    = aws_key_pair.keypair.key_name
    vpc_security_group_ids      = ["${aws_security_group.bastionhostSG.id}"]
}

resource "aws_instance" "SQL_A" {
    ami                         = lookup(var.aws_ubuntu_awis,var.region)
    instance_type               = "t2.micro"
    tags = {
        Name                    = "${var.environment}-SQL001"
        Environment             = "${var.environment}"
        sshUser                 = "ubuntu"
    }
    subnet_id                   = aws_subnet.private-db-az-a.id
    key_name                    = aws_key_pair.keypair.key_name
    vpc_security_group_ids      = ["${aws_security_group.DBServerSG.id}"]
}

resource "aws_instance" "SQL_B" {
    ami                         = lookup(var.aws_ubuntu_awis,var.region)
    instance_type               = "t2.micro"
    tags = {
        Name                    = "${var.environment}-SQL002"
        Environment             = "${var.environment}"
        sshUser                 = "ubuntu"
    }
    subnet_id                   = aws_subnet.private-db-az-b.id
    key_name                    = aws_key_pair.keypair.key_name
    vpc_security_group_ids      = ["${aws_security_group.DBServerSG.id}"]
}

resource "aws_elb" "lb" {
    name_prefix                 = "${var.environment}-"
    subnets                     = ["${aws_subnet.public-web-az-a.id}", "${aws_subnet.public-web-az-b.id}"]
    health_check {
        healthy_threshold       = 2
        unhealthy_threshold     = 2
        timeout                 = 3
        target                  = "HTTP:80/"
        interval                = 30
    }
    listener {
        instance_port           = 80
        instance_protocol       = "http"
        lb_port                 = 80
        lb_protocol             = "http"
    }
    cross_zone_load_balancing   = true
    instances                   = ["${aws_instance.WEB_A.id}", "${aws_instance.WEB_B.id}"]
    security_groups             = ["${aws_security_group.LoadBalancerSG.id}"]
}