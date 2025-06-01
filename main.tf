resource "proxmox_pool" "cluster_pool" {
  count = (var.control_plane_count + var.worker_count) > 0 ? 1 : 0

  poolid  = var.cluster_name
  comment = "Resource pool for the ${var.cluster_name} cluster"
}

# Control Plane Nodes
resource "proxmox_vm_qemu" "control_plane_node" {
  count = var.control_plane_count

  lifecycle {
    ignore_changes = [
      vm_state
    ]
  }

  # Basic VM config
  name        = "${var.control_plane_name_prefix}${format(var.node_name_suffix_format, count.index + 1)}"
  target_node = var.proxmox_target_node
  tags        = join(";", concat(var.common_tags, var.control_plane_tags))
  pool        = proxmox_pool.cluster_pool[0].poolid
  vmid        = var.control_plane_base_vmid != 0 ? var.control_plane_base_vmid + count.index : 0 # 0 means Proxmox picks next available

  # OS / Agent / Display
  qemu_os = var.qemu_os
  agent   = var.agent_enabled ? 1 : 0
  bios    = "seabios" # Or "ovmf" for UEFI

  vga {
    type = var.vga_type
  }

  # Cloning
  clone      = var.template_name
  full_clone = var.full_clone

  # State and protection
  vm_state   = var.initial_vm_state
  protection = var.protection

  # Hardware
  cores   = coalesce(var.control_plane_vm_cores, var.default_vm_cores)
  sockets = coalesce(var.control_plane_vm_sockets, var.default_vm_sockets)
  memory  = coalesce(var.control_plane_vm_memory, var.default_vm_memory)
  scsihw  = var.scsihw

  # Boot order
  boot = "order=${var.cdrom_ide_slot};${var.os_disk_slot};net0;${var.cloudinit_ide_slot}"

  # Network configuration (net0)
  network {
    id       = 0
    model    = var.network_model
    bridge   = var.network_bridge
    firewall = var.network_firewall
  }

  # Disk configuration
  disks {
    scsi {
      scsi0 {
        disk {
          storage    = coalesce(var.control_plane_os_disk_storage, var.default_os_disk_storage)
          size       = coalesce(var.control_plane_os_disk_size, var.default_os_disk_size)
          discard    = var.os_disk_discard
          iothread   = var.os_disk_iothread
          emulatessd = var.os_disk_ssd
        }
      }
    }
    ide {
      ide0 {
        cloudinit {
          storage = coalesce(var.control_plane_cloudinit_disk_storage, var.default_cloudinit_disk_storage)
        }
      }
      ide2 {
        cdrom {}
      }
    }
  }

  # Cloud-Init configuration
  ipconfig0 = length(var.control_plane_ip_configs) > count.index && var.control_plane_ip_configs[count.index] != "" && var.control_plane_ip_configs[count.index] != null ? var.control_plane_ip_configs[count.index] : var.default_ip_config

  ciuser       = var.ciuser
  cipassword   = var.cipassword
  sshkeys      = local.ssh_keys_content
  nameserver   = var.nameserver
  searchdomain = var.searchdomain
}

# Worker Nodes
resource "proxmox_vm_qemu" "worker_node" {
  count = var.worker_count

  lifecycle {
    ignore_changes = [vm_state]
  }

  name        = "${var.worker_name_prefix}${format(var.node_name_suffix_format, count.index + 1)}"
  target_node = var.proxmox_target_node
  tags        = join(";", concat(var.common_tags, var.worker_tags))
  pool        = proxmox_pool.cluster_pool[0].poolid
  vmid        = var.worker_base_vmid != 0 ? var.worker_base_vmid + count.index : 0

  qemu_os = var.qemu_os
  agent   = var.agent_enabled ? 1 : 0
  bios    = "seabios"

  vga {
    type = var.vga_type
  }

  clone      = var.template_name
  full_clone = var.full_clone

  vm_state   = var.initial_vm_state
  protection = var.protection

  cores   = coalesce(var.worker_vm_cores, var.default_vm_cores)
  sockets = coalesce(var.worker_vm_sockets, var.default_vm_sockets)
  memory  = coalesce(var.worker_vm_memory, var.default_vm_memory)
  scsihw  = var.scsihw

  boot = "order=${var.cdrom_ide_slot};${var.os_disk_slot};net0;${var.cloudinit_ide_slot}"

  network {
    id       = 0
    model    = var.network_model
    bridge   = var.network_bridge
    firewall = var.network_firewall
  }

  # Disk configuration
  disks {
    scsi {
      scsi0 {
        disk {
          storage    = coalesce(var.worker_os_disk_storage, var.default_os_disk_storage)
          size       = coalesce(var.worker_os_disk_size, var.default_os_disk_size)
          discard    = var.os_disk_discard
          iothread   = var.os_disk_iothread
          emulatessd = var.os_disk_ssd
        }
      }
    }
    ide {
      ide0 {
        cloudinit {
          storage = coalesce(var.worker_cloudinit_disk_storage, var.default_cloudinit_disk_storage)
        }
      }
      ide2 {
        cdrom {}
      }
    }
  }

  ipconfig0 = length(var.worker_ip_configs) > count.index && var.worker_ip_configs[count.index] != "" && var.worker_ip_configs[count.index] != null ? var.worker_ip_configs[count.index] : var.default_ip_config

  ciuser       = var.ciuser
  cipassword   = var.cipassword
  sshkeys      = local.ssh_keys_content
  nameserver   = var.nameserver
  searchdomain = var.searchdomain
}
