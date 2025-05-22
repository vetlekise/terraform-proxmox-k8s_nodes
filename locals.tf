locals {
  ssh_keys_content = var.ssh_public_keys_file != null ? file(var.ssh_public_keys_file) : var.ssh_public_keys
}
