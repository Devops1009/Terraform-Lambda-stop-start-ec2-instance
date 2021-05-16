

variable "file1" {
  default = "ec2_stop.py"
}

variable "file2" {
  default = "ec2_start.py"
}

variable "startfunction" {
  default = "ec2-start_lambda"
}

variable "stopfunction" {
  default = "ec2-stop_lambda"
}

variable "startjobtime" {
  default = "cron(46 5 ? * SUN *)"
}

variable "stopjobtime" {
  default = "cron(41 5 ? * SUN *)"
}
