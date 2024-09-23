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
    ["-vnc", "0.0.0.0:1"],  # Explicit VNC argument for port 5901
//     ["-serial", "mon:stdio"], # enables serial output
//     ["-m", "2048"],
    ["-net", "user,hostfwd=tcp::2222-:22"],
//     ["-net", "nic"]
  ]
  iso_checksum      = "sha256:e240e4b801f7bb68c20d1356b60968ad0c33a41d00d828e74ceb3364a0317be9"
  ssh_port          = 2222
  ssh_username      = var.ssh_username
  ssh_password      = var.ssh_password
  ssh_timeout       = "60m"

  boot_command = [
    "<esc><wait>",
    "linux /casper/vmlinuz --- autoinstall ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ",
    "<enter><wait>",
    "initrd /casper/initrd<enter><wait>",
    "boot<enter>"
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
      "sudo apt install -y openssh-server python3",
      "sudo systemctl enable ssh",
      "sudo systemctl start ssh",
      "sudo chmod +x /home/sysadmin/deploy-script.sh",
      "python3 -m http.server {{ .HTTPPort }} --directory /etc/cloud/cloud.cfg.d/"
    ]
  }

  provisioner "file" {
    source      = "./config/cloud-config.yaml"
    destination = "/etc/cloud/cloud.cfg.d/99_custom.cfg"
  }

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
