variable "output_format" {
  type        = string
  default     = "img"
  description = "Choose the output format: 'raw' for raw format or 'img' for regular image."
}


variable "qemu_accelerator" {
  type        = string
  default     = "kvm"
  description = "Qemu accelerator to use. On Linux use kvm and macOS use hvf."
}

variable "ubuntu_version" {
  type        = string
  default     = "noble"
  description = "Ubuntu codename version (i.e. 20.04 is focal and 22.04 is jammy)"
}