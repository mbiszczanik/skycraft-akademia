// modules/dns.bicep
// Obie strefy DNS platformy SkyCraft: publiczna z rekordem `play` i prywatna
// z rekordem `prod-db` oraz linkami do sieci huba i prod. Wdrażany do grupy
// platform-skycraft-swc-rg (strefy DNS są globalne, stąd location: 'global').

@description('Nazwa strefy publicznej')
param publicZoneName string = 'skycraft.example.com'

@description('Nazwa strefy prywatnej')
param privateZoneName string = 'skycraft.internal'

@description('Adres publiczny dla rekordu A `play` (wyjście modułu publicip)')
param playIpAddress string

@description('TTL rekordu `play` w sekundach (w portalu na spotkaniu 3: 300)')
param playTtl int = 300

@description('Adres prywatny dla rekordu A `prod-db`')
param prodDbIpAddress string = '10.2.3.10'

@description('TTL rekordu `prod-db` w sekundach (w portalu na spotkaniu 3: 300)')
param prodDbTtl int = 300

@description('ID sieci huba (link bez autorejestracji)')
param hubVnetId string

@description('ID sieci prod (link z autorejestracją)')
param prodVnetId string

@description('Nazwa linku do huba, taka jak wpisana w portalu na spotkaniu 3')
param hubLinkName string = 'hub-vnet-link'

@description('Nazwa linku do prod, taka jak wpisana w portalu na spotkaniu 3')
param prodLinkName string = 'prod-vnet-link'

@description('Tagi zasobów')
param tags object

// Strefa publiczna i rekord `play`
resource publicZone 'Microsoft.Network/dnsZones@2018-05-01' = {
  name: publicZoneName
  location: 'global'
  tags: tags
  properties: {
    zoneType: 'Public'
  }
}

resource playRecord 'Microsoft.Network/dnsZones/A@2018-05-01' = {
  parent: publicZone
  name: 'play'
  properties: {
    TTL: playTtl
    ARecords: [
      {
        ipv4Address: playIpAddress
      }
    ]
  }
}

// Strefa prywatna, rekord `prod-db` i dwa linki
resource privateZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateZoneName
  location: 'global'
  tags: tags
}

resource prodDbRecord 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  parent: privateZone
  name: 'prod-db'
  properties: {
    ttl: prodDbTtl
    aRecords: [
      {
        ipv4Address: prodDbIpAddress
      }
    ]
  }
}

// Linki bez tagów: okno „Add virtual network link” w portalu ich nie ma, a what-if pokazałby Modify.
resource hubLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateZone
  name: hubLinkName
  location: 'global'
  properties: {
    virtualNetwork: {
      id: hubVnetId
    }
    registrationEnabled: false
  }
}

resource prodLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateZone
  name: prodLinkName
  location: 'global'
  properties: {
    virtualNetwork: {
      id: prodVnetId
    }
    registrationEnabled: true
  }
}

output publicZoneId string = publicZone.id
output privateZoneId string = privateZone.id
output playFqdn string = 'play.${publicZoneName}'
output nameServers array = publicZone.properties.nameServers
