import requests
import json

response = requests.get("https://de1.api.radio-browser.info/json/stations", params={"limit": 100000})
stations = response.json()

filtered = []

for s in stations:
    filtered.append({
        "name": s.get("name"),
        "url_resolved": s.get("url_resolved"),
        "country": s.get("country"),
        "countrycode": s.get("countrycode"),
        "tags": s.get("tags"),
        "clickcount": s.get("clickcount"),
        "language": s.get("language"),
        "favicon": s.get("favicon"),
        "codec": s.get("codec"),
        "bitrate": s.get("bitrate"),
        "hls": s.get("hls")
    })

with open("stations_raw.json", "w", encoding="utf-8") as f:
    json.dump(filtered, f, ensure_ascii=False, indent=2)
