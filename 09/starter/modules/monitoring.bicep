// Monitoring maszyny świata: workspace, reguła zbierania danych, agent.
// Wzór: lab 5.1 (kroki 5.1.1-5.1.2), bez Syslog i bez VM insights.

@description('Nazwa workspace Log Analytics, np. prod-skycraft-swc-law')
param workspaceName string

@description('Nazwa reguły zbierania danych, np. prod-skycraft-swc-dcr-world')
param dcrName string

param location string

@description('Cztery obowiązkowe tagi ze spotkania 2')
param tags object

@description('Nazwa maszyny świata (wyjście vmName modułu worldVm)')
param vmName string

resource vm 'Microsoft.Compute/virtualMachines@2024-07-01' existing = {
  name: vmName
}

resource workspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: workspaceName
  location: location
  tags: tags
  properties: {
    sku: { name: 'PerGB2018' }
    retentionInDays: 30
  }
}

// Co zbierać (liczniki wydajności do tabeli Perf) i dokąd wysyłać (workspace).
resource dcr 'Microsoft.Insights/dataCollectionRules@2023-03-11' = {
  name: dcrName
  location: location
  tags: tags
  kind: 'Linux'
  properties: {
    dataSources: {
      performanceCounters: [
        {
          name: 'perfCounters'
          streams: [ 'Microsoft-Perf' ]
          samplingFrequencyInSeconds: 60
          counterSpecifiers: [
            'Processor(*)\\% Processor Time'
            'Memory(*)\\% Used Memory'
            'Memory(*)\\Available MBytes Memory'
          ]
        }
      ]
    }
    destinations: {
      logAnalytics: [
        { name: 'workspace', workspaceResourceId: workspace.id }
      ]
    }
    dataFlows: [
      { streams: [ 'Microsoft-Perf' ], destinations: [ 'workspace' ] }
    ]
  }
}

// Bez powiązania reguła nie wie, z której maszyny zbierać.
resource association 'Microsoft.Insights/dataCollectionRuleAssociations@2023-03-11' = {
  name: '${dcrName}-assoc'
  scope: vm
  properties: {
    dataCollectionRuleId: dcr.id
  }
}

// Tagi wprost: polityka ze spotkania 2 odrzuca zasób bez tagu.
resource agent 'Microsoft.Compute/virtualMachines/extensions@2024-07-01' = {
  parent: vm
  name: 'AzureMonitorLinuxAgent'
  location: location
  tags: tags
  properties: {
    publisher: 'Microsoft.Azure.Monitor'
    type: 'AzureMonitorLinuxAgent'
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
  }
}

output workspaceId string = workspace.id
output workspaceName string = workspace.name
output dcrId string = dcr.id
