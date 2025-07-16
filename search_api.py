from flask import Flask, request, jsonify
from flask_cors import CORS
from elasticsearch import Elasticsearch

app = Flask(__name__)
CORS(app)

BONSAI_USERNAME = "e0zk42nhkp"
BONSAI_PASSWORD = "h09w8k79sy"
BONSAI_HOST = "https://globe-radio-search-1981816204.eu-central-1.bonsaisearch.net"

es = Elasticsearch(
    BONSAI_HOST,
    basic_auth=(BONSAI_USERNAME, BONSAI_PASSWORD),
    verify_certs=True
)

@app.route("/search")
def search():
    query = request.args.get("q", "")
    if not query:
        return jsonify([])

    try:
        result = es.search(index="radio_stations", query={"match": {"name": query}})
        hits = result["hits"]["hits"]
        return jsonify([hit["_source"] for hit in hits])
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run()
