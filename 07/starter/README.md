# Starter spotkania 7: panel gracza

Dwa pliki do folderu `app/` w Twoim repozytorium `skycraft-platform` (krok 2 quest logu):

- [`app/app.py`](app/app.py): panel gracza we Flasku. Pokazuje, kto jest zalogowany, czy serwer świata odpowiada pod adresem z ustawienia `WORLD_SERVER_URL`, numer wersji z `APP_VERSION` i nazwę kontenera.
- [`app/requirements.txt`](app/requirements.txt): Flask i gunicorn.

Kodu aplikacji nie zmieniasz. Twoja część to `Dockerfile` i `.dockerignore` obok tych plików, z Copilotem, według listy kontrolnej w quest logu.

Aplikacja słucha na porcie 8080 i nie ma innych stron niż `/`. Bez ustawienia `WORLD_SERVER_URL` pokazuje serwer świata jako offline, a bez logowania przez App Service pisze „niezalogowany”; oba stany są na zajęciach zamierzone.
