output "PA_public_ip" {
    value = azurerm_public_ip.pa-pip.*.ip_address
}
