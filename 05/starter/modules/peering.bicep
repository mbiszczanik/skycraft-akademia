// modules/peering.bicep
// Jedna strona peeringu. Z main.bicep wywołujesz go dwa razy: raz w grupie huba
// (hub-to-prod), raz w grupie prod (prod-to-hub). Sieć lokalna już istnieje
// (moduł network), więc bierzemy ją przez `existing` po nazwie.

@description('Nazwa sieci lokalnej w grupie, do której kierujesz ten moduł')
param localVnetName string

@description('Nazwa peeringu, taka jak w portalu (hub-to-prod albo prod-to-hub)')
param peeringName string

@description('ID sieci zdalnej (wyjście vnetId drugiego modułu network)')
param remoteVnetId string

@description('Ruch przekazany z sieci zdalnej (w portalu na spotkaniu 3: Allow)')
param allowForwardedTraffic bool = true

@description('Sieć zdalna może używać bramy z tej sieci')
param allowGatewayTransit bool = false

@description('Ta sieć używa bramy z sieci zdalnej')
param useRemoteGateways bool = false

resource localVnet 'Microsoft.Network/virtualNetworks@2023-05-01' existing = {
  name: localVnetName
}

resource peering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-05-01' = {
  parent: localVnet
  name: peeringName
  properties: {
    remoteVirtualNetwork: {
      id: remoteVnetId
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: allowForwardedTraffic
    allowGatewayTransit: allowGatewayTransit
    useRemoteGateways: useRemoteGateways
    // Wartość domyślna Azure; wpisana jawnie, żeby what-if nie zgłaszał jej jako usuniętej.
    doNotVerifyRemoteGateways: false
  }
}

output peeringId string = peering.id
