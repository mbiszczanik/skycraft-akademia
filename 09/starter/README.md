# Starter spotkania 9: monitoring maszyny świata

`modules/monitoring.bicep` stawia w grupie prod workspace Log Analytics, regułę zbierania danych z licznikami wydajności i agenta Azure Monitor na maszynie świata. Wzór to lab 5.1, kroki 5.1.1-5.1.2.

## Co kopiujesz

1. `modules/monitoring.bicep` do folderu `modules/` swojego repozytorium `skycraft-platform`.
2. Do `modules/vm.bicep`, w zasobie `vm`, obok `tags: tags`, jedną linię. Agent wysyła dane w imieniu maszyny, więc maszyna potrzebuje własnej tożsamości:

   ```bicep
   identity: { type: 'SystemAssigned' }
   ```

3. Do `main.bicep`, po module `worldVm`:

   ```bicep
   module monitoring 'modules/monitoring.bicep' = {
     name: 'monitoring'
     scope: prodRg
     params: {
       workspaceName: '${prodPrefix}-law'
       dcrName: '${prodPrefix}-dcr-world'
       location: location
       tags: prodTags
       vmName: worldVm.outputs.vmName
     }
   }

   output workspaceName string = monitoring.outputs.workspaceName
   ```

Nazwy `prodRg`, `prodPrefix`, `prodTags`, `location` i `worldVm` masz ze spotkań 5-6. Jeśli Twój moduł maszyny nie ma wyjścia `vmName`, porównaj go z rozwiązaniem wzorcowym spotkania 6.
