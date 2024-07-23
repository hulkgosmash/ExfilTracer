variable "region" {
    default = "ap-southeast-2"
    description = "AWS Region"
}

variable "ClientID" {
    default = "ClientID"
    description = "Unique Client ID to differentiate resources"
}

variable "Key_name" {
    default = "hulk"
    description = "SSH Key"
}

#variable "Zone_id" {
#    default = "Z0789527ZNPTVU7DAVNZ"
#    description = "Zone ID"
#}

variable "Private_key" {
    default = "hulk.pem"
    description = "Private key file location"
}

variable "Root_domain" {
    default = "hulkgosmash.com"
    description = "Root Domain"
}

variable "AMI" {
    default = "ami-076fe60835f136dc9"
    description = "AMI ID for your region (Only tested with Ubuntu 22.04 64-bit(x86)"
}

variable "Instance_type" {
    default = "t2.micro"
    description = "Set instance type t2.micro seems sufficient"
}

variable "IP_Address" {
    default = "0.0.0.0/0"
    description = "IP_Address to restrict traffic to"
}

variable "Password" {
    default = "P@ssw0rd"
    description = "IP_Address to restrict traffic to"
}