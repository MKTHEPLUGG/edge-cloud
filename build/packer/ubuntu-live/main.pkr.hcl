packer {
  required_plugins {
    qemu = {
      version = ">= 1.0.9"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

source "qemu" "custom_image" {
    vm_name     = "test"
    
    iso_url      = var.iso_url
    iso_checksum = "file:${var.iso_checksum}"

    # Location of Cloud-Init / Autoinstall Configuration files
    # Will be served via an HTTP Server from Packer
    http_directory = "config/"

    # Boot Commands when Loading the ISO file with OVMF.fd file (Tianocore) / GrubV2
    boot_command = [
        "<spacebar><wait><spacebar><wait><spacebar><wait><spacebar><wait><spacebar><wait>",
        "e<wait>",
        "<down><down><down><end>",
        " autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/",
        "<f10>"
    ]
    
    boot_wait = "5s"

    # QEMU specific configuration
    cpus             = 4
    memory           = 4096
    accelerator      = "kvm" # use none here if not using KVM
    disk_size        = "30G"
    disk_compression = true

    efi_firmware_code = "/usr/share/OVMF/OVMF_CODE_4M.fd"
    efi_firmware_vars = "/usr/share/OVMF/OVMF_VARS_4M.fd"
    efi_boot = true


    # Final Image will be available in `output/packerubuntu-*/`
    output_directory = "output/"

    # SSH configuration so that Packer can log into the Image
    ssh_password    = "packerubuntu"
    ssh_username    = "admin"
    ssh_timeout     = "20m"
    shutdown_command = "echo 'packerubuntu' | sudo -S shutdown -P now"
    headless        = false # NOTE: set this to true when using in CI Pipelines
}

build {
    name    = "custom_build"
    sources = [ "source.qemu.custom_image" ]

    # Wait till Cloud-Init has finished setting up the image on first-boot
    provisioner "shell" {
        inline = [
            "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for Cloud-Init...'; sleep 1; done" 
        ]
    }

    # Finally Generate a Checksum (SHA256) which can be used for further stages in the `output` directory
//     post-processor "checksum" {
//         checksum_types      = [ "sha256" ]
//         output              = "${local.output_dir}/${local.vm_name}.{{.ChecksumType}}"
//         keep_input_artifact = true
//     }
}