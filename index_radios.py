from elasticsearch import Elasticsearch
import requests

# Elasticsearch client
es = Elasticsearch(
    ['https://e0zk42nhkp:h09w8k79sy@globe-radio-search-1981816204.eu-central-1.bonsaisearch.net:443'],
    use_ssl=True,
    verify_certs=True
)

index_name = "radio_stations"

# Fetch stations
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
