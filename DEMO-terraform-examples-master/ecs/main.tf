# Configure the HuaweiCloud Provider with AK/SK
# This will work with a single defined/default network, otherwise you need to specify network
# to fix errors about multiple networks found.
provider "huaweicloud" {
  tenant_name = var.region
  region      = var.region
  access_key  = var.ak
  secret_key  = var.sk
  # the auth url format follows: https://iam.{region_id}.myhwclouds.com:443/v3
  auth_url    = "https://iam.${var.region}.myhuaweicloud.com/v3"
}

# Create a VPC, Network and Subnet
resource "huaweicloud_vpc_v1" "vpc_v1" {
  name = "vpc-tftest"
  cidr = "192.168.0.0/16"
}

resource "huaweicloud_vpc_subnet_v1" "subnet_v1" {
  name       = "subnet-test"
  cidr       = "192.168.0.0/24"
  gateway_ip = "192.168.0.1"
  vpc_id     = huaweicloud_vpc_v1.vpc_v1.id
}

# Create Security Group and rule ssh
resource "huaweicloud_networking_secgroup_v2" "secgroup_1" {
  name        = "secgroup_1"
  description = "My neutron security group"
}

resource "huaweicloud_networking_secgroup_rule_v2" "secgroup_rule_1" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = huaweicloud_networking_secgroup_v2.secgroup_1.id
}

# Create ECS

resource "huaweicloud_compute_instance_v2" "basic" {
  name              = "basic"
  image_name        = "Ubuntu 18.04 server 64bit"
  flavor_name       = "s3.medium.2"
  key_pair          = "KeyPair-TF"
  security_groups   = [huaweicloud_networking_secgroup_v2.secgroup_1.name]
  availability_zone = "${var.region}a"

  network {
    name = huaweicloud_vpc_v1.vpc_v1.id
  }
}

# Variables
variable "ak" {
  type = string
}

variable "sk" {
  type = string
}

variable "region" {
  type = string
}
