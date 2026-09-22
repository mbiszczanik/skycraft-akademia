# Starter spotkania 5: moduły DNS i peeringu

Dwa moduły od prowadzącego, żeby na zajęciach starczyło czasu na `main.bicep` i pierwszy save game. Nie piszesz ich, ale czytasz tak, jakbyś miał je ocenić na przeglądzie kodu.

## Jak wgrać

1. Pobierz `modules/dns.bicep` i `modules/peering.bicep` do folderu `modules/` w swoim repozytorium `skycraft-platform`.
2. `az bicep build --file modules/dns.bicep` i `az bicep build --file modules/peering.bicep`: oba bez błędów i ostrzeżeń.
3. `git add modules && git commit -m "starter: dns i peering"`.

## Co sprawdzić w przeglądzie

- Każdy parametr ma `@description`; wartości domyślne to te, które wpisałeś w portalu na spotkaniu 3 (nazwy stref, nazwy linków, TTL, ruch przekazany). Jeśli u Ciebie w portalu jest inaczej, zmieniasz wartość w `main.bicep`, nie w module.
- `dns.bicep` nie zna adresu `play`: dostaje go z wyjścia modułu `publicip`. To jedyny sposób, żeby rekord wskazywał na adres, który naprawdę istnieje.
- `peering.bicep` opisuje jedną stronę. Peering ma dwie i każda leży w innej grupie zasobów, dlatego moduł wywołujesz dwa razy, z innym `scope:`.
- Kolejność: `localVnetName` bierz z wyjścia modułu sieci (`prodVnet.outputs.vnetName`), nie wpisaną na sztywno, bo `existing` nie tworzy zależności i przy odtwarzaniu prod peering wystartowałby przed siecią. Kolejności stron peeringu nie da się wyprowadzić z danych, bo żadna nie używa wyjścia drugiej. Po utworzeniu pierwszej strony peering ma stan *Initiated*, po drugiej *Connected*; obie strony wołane równolegle potrafią się zderzyć na tej samej sieci, dlatego drugą stronę wołasz po pierwszej (`dependsOn: [hubToProd]`, jedyny `dependsOn` w `main.bicep`).
- Na sztywno są tylko rzeczy, które definiują ten moduł: `location: 'global'` (strefy DNS nie mają regionu), nazwy rekordów `play` i `prod-db`, autorejestracja wyłączona dla huba i włączona dla prod oraz `allowVirtualNetworkAccess: true` (bez tego peering nie ma sensu). Reszta to parametry.
