packer {
  required_plugins {
    qemu = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

source "qemu" "ubuntu" {
  iso_url           = var.iso_url
  output_directory  = "output-ubuntu-image"
  disk_size         = 20000
  format            = "raw"
  headless          = true
  qemuargs          = [
//     ["-display", "vnc=:1"],  # binds VNC to display 1
//     ["-serial", "mon:stdio"], # enables serial output
//     ["-m", "2048"],
    ["-net", "user,hostfwd=tcp::2222-:22"],
//     ["-net", "nic"]
  ]
  iso_checksum      = "file:${var.iso_checksum}"
  ssh_port          = 2222
  ssh_username      = var.ssh_username
  ssh_password      = var.ssh_password
  ssh_timeout       = "60m"
  efi_firmware_code = "/usr/share/OVMF/OVMF_CODE_4M.fd"
  efi_firmware_vars = "/usr/share/OVMF/OVMF_VARS_4M.fd"
  efi_boot = true

  http_directory = "./config"  # Serving files from the 'config' directory, packer will use this to serve the config file via http

  boot_command = [
    "<spacebar><wait><spacebar><wait><spacebar><wait><spacebar><wait><spacebar><wait>",
    "e<wait>",
    "<down><down><down><end>",
    " autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/",
    "<f10>"
  ]
}

build {
  sources = ["source.qemu.ubuntu"]

  provisioner "shell" {
    environment_vars = [
      "IMAGE_NAME=$(basename ${var.iso_url})"
    ]
    inline = [
      "sudo apt-get update -y && sudo apt upgrade -y",
      "sudo systemctl enable ssh",
      "sudo systemctl start ssh",
      "sudo chmod +x /home/sysadmin/deploy-script.sh",
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for Cloud-Init...'; sleep 1; done"
    ]
  }

//   provisioner "file" {
//     source      = "./config/cloud-config.yaml"
//     destination = "/etc/cloud/cloud.cfg.d/99_custom.cfg"
//   }

  provisioner "file" {
    source      = "./config/p10k.zsh"
    destination = "/home/sysadmin/.p10k.zsh"
  }

  provisioner "file" {
    source      = "./config/deploy-script.sh"
    destination = "/home/sysadmin/deploy-script.sh"
  }

  post-processor "shell-local" {
    inline = [
      "qemu-img convert -O raw output-ubuntu-image/packer-qemu output-ubuntu-image/ubuntu-custom-image.raw"
    ]
  }
}
