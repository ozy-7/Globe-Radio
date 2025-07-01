import requests
from elasticsearch import Elasticsearch


es = Elasticsearch("http://localhost:9200")


index_name = "radio_stations"


response = requests.get("https://de1.api.radio-browser.info/json/stations")
stations = response.json()


if es.indices.exists(index=index_name):
    es.indices.delete(index=index_name)

es.indices.create(index=index_name)


for station in stations:
    doc = {
        "name": station.get("name"),
        "country": station.get("country"),
        "language": station.get("language"),
        "tags": station.get("tags"),
        "url": station.get("url"),
        "homepage": station.get("homepage")
    }
    es.index(index=index_name, body=doc)

print(f"{len(stations)} stations loaded.")
