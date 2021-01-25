
provider "aws" {
  region = "us-west-2"
}

provider "random" {}

resource "random_pet" "name" {}

## variables.tf of module
variable "subnet" {
  default = "10.0.0.0/24"
}
variable "cidr_block" {
  default = "10.0.0.0/16"
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr_block
  tags = {
    Name = "${random_pet.name.id}_vpc"
    Env  = random_pet.name.id
  }
}
resource "aws_subnet" "subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.subnet
  map_public_ip_on_launch = "true"

  tags = {
    Name = "${random_pet.name.id}_subnet"
    Env  = random_pet.name.id
  }
}
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id
tags = {
    Name = "${random_pet.name.id}_gw"
    Env  = random_pet.name.id
  }
}
resource "aws_default_route_table" "route_table" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id
route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
tags = {
    Name = "default route table"
    env  = random_pet.name.id
  }
}

resource "aws_instance" "web" {
  ami           = "ami-a0cfeed8"
  instance_type = "t2.micro"
  user_data     = file("init-script.sh")
  subnet_id              = aws_subnet.subnet.id
  #vpc_security_group_ids = var.vpc_security_group_ids # list
    
  tags = {
    Name = random_pet.name.id
  }
}

output "domain-name" {
  value = aws_instance.web.public_dns
}

output "application-url" {
  value = "${aws_instance.web.public_dns}/index.php"
}
 
