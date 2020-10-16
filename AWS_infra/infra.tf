provider "aws" {
 region  = "ap-southeast-1"
 profile = "default"
}

variable "enter_your_key_name" {
                type = string
}

resource "aws_instance" "myterra01" {
  availability_zone = "ap-southeast-1a"
  ami           = "ami-015a6758451df3cb9"
  key_name      =  var.enter_your_key_name
  instance_type = "t2.micro"
  security_groups = ["Redhat-Ansible" ]

  tags = {
    Name = "terra-launched01"
  }

  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("C:/Users/DELL-PC/Downloads/terra.pem")
    host     = aws_instance.myterra01.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      " sudo yum install httpd -y ",
      "sudo systemctl restart httpd ",
      " sudo systemctl enable httpd",
      " sudo yum install git -y ",
      
    ]
  }
}

  output  "myos_ip" {
     value = "aws_instance.myterra01.public_ip"
} 


resource "aws_ebs_volume" "ebs02" {
  availability_zone = "ap-southeast-1a"
  size              = 2

  tags = {
    Name = "ebs_attached_instance"
  }
}

output  "forebs" {
         value = "aws_ebs_volume.ebs02"
}



resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdd"
  volume_id   = aws_ebs_volume.ebs02.id
  instance_id = aws_instance.myterra01.id
}

resource "null_resource" "nulllocal" {

  provisioner "local-exec" {
    command = "echo ${aws_instance.myterra01.public_ip}  > publicip.txt"
  }
}



resource "null_resource" "nullloca3" {
depends_on = [
          aws_volume_attachment.ebs_att,
]
connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("C:/Users/DELL-PC/Downloads/terra.pem")
    host     = aws_instance.myterra01.public_ip
  }

provisioner "remote-exec" {
    inline = [
      " sudo mkfs.ext4 /dev/xvdh ",
      " sudo mount /dev/xvdh  /var/www/html ",
      " sudo git clone https://github.com/Ajaydiwakar/multicloud.git  /var/www/html/" ,
      
    ]
  }
}



resource "null_resource" "nullloca2" {
depends_on = [
          null_resource.nullloca3,
]
  provisioner "local-exec" {
    command = "chrome ${aws_instance.myterra01.public_ip}  > publicip.txt"
  }
}
