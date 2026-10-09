"""Panel gracza SkyCraft: kto jest zalogowany i czy serwer świata odpowiada.

Ustawienia (zmienne środowiskowe):
  WORLD_SERVER_URL  adres serwera świata, np. http://10.2.2.4:8085 (brak = offline)
  APP_VERSION       numer wersji pokazywany na stronie (domyślnie 1)
Nazwę zalogowanej osoby dopisuje App Service w nagłówku X-MS-CLIENT-PRINCIPAL-NAME
(Easy Auth); bez logowania nagłówka nie ma.
"""
import os
import socket
import urllib.error
import urllib.request
from html import escape

from flask import Flask, request

app = Flask(__name__)

TIMEOUT_S = 2

PAGE = """<!doctype html>
<html lang="pl">
<head><meta charset="utf-8"><title>Panel gracza SkyCraft</title></head>
<body style="font-family: sans-serif; max-width: 40rem; margin: 3rem auto">
<h1>Panel gracza SkyCraft</h1>
<p>Zalogowany: <strong>{player}</strong></p>
<p>Serwer świata: <strong>{status}</strong> <small>({world})</small></p>
<p>Wersja: {version} · kontener: {host}</p>
</body>
</html>
"""


def world_status(url):
    """'online', gdy serwer świata odpowie w ciągu TIMEOUT_S sekund (jakimkolwiek kodem), inaczej 'offline'."""
    if not url:
        return "offline"
    try:
        with urllib.request.urlopen(url, timeout=TIMEOUT_S):
            return "online"
    except urllib.error.HTTPError:
        return "online"  # serwer odpowiedział, choćby kodem błędu
    except (urllib.error.URLError, OSError, ValueError):
        return "offline"


@app.get("/")
def index():
    world = os.environ.get("WORLD_SERVER_URL", "")
    return PAGE.format(
        player=escape(request.headers.get("X-MS-CLIENT-PRINCIPAL-NAME", "niezalogowany")),
        status=world_status(world),
        world=escape(world or "brak ustawienia WORLD_SERVER_URL"),
        version=escape(os.environ.get("APP_VERSION", "1")),
        host=escape(socket.gethostname()),
    )
