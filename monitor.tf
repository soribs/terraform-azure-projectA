resource "azurerm_monitor_diagnostic_setting" "vm-diagnostics" {
  name               = "linux-vm-diagnostics"
  target_resource_id = azurerm_linux_virtual_machine.vm-linux-prod-spain-001.id
  storage_account_id = azurerm_storage_account.storage-account["stprojectaprodspain1"].id

  #   enabled_log {
  #     category = "AuditEvent"
  #   }

  enabled_metric {
    category = "AllMetrics"
  }
}

resource "azurerm_monitor_data_collection_rule" "data-collection-rule" {
  name                = "linux-vm-rule"
  location            = module.resource_group.resource_group_location
  resource_group_name = module.resource_group.resource_group_name
  kind                = "Linux"

  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.workspace.id
      name                  = "log-analytics-dest"
    }
  }

  # I choose log_analytics because storage_blop_direct is not compatible 
  # with "streams = [Microsoft-Syslog]" in the 4.67.0 version

  data_flow {
    streams      = ["Microsoft-Syslog"]
    destinations = ["log-analytics-dest"]
  }

  data_sources {
    syslog {
      facility_names = ["*"]
      log_levels     = ["*"]
      name           = "datasource-syslog"
      streams        = ["Microsoft-Syslog"]
    }
  }

}

resource "azurerm_monitor_data_collection_rule_association" "linux-vm-rule-association" {
  name                    = "Linux-dcra"
  target_resource_id      = azurerm_linux_virtual_machine.vm-linux-prod-spain-001.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.data-collection-rule.id
}

resource "azurerm_log_analytics_workspace" "workspace" {
  name                = "log-projectA-prod-spain-001"
  location            = module.resource_group.resource_group_location
  resource_group_name = module.resource_group.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}