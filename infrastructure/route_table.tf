resource "azurerm_route_table" "RT" {
  name                          = "no_bgp_rt"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  disable_bgp_route_propagation = true

  depends_on = [
    azurerm_resource_group.rg
  ]

  route {
    name = "default"
    address_prefix = "0.0.0.0/0"
    next_hop_type = "VirtualAppliance"
    next_hop_in_ip_address = module.PA[0].azurerm_network_interface_private_ip_address[1]
  }
}

resource "azurerm_subnet_route_table_association" "RT" {
  for_each = {
    vnet1 = 1
    vnet2 = 2
  }
  subnet_id      = module.vnet[each.value].vnet_subnets[0]
  route_table_id = azurerm_route_table.RT.id
}