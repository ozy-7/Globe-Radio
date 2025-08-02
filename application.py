from flask import Flask, request, jsonify
from flask_cors import CORS
import json

app = Flask(__name__)
CORS(app)


with open('/home/ubuntu/bulk_stations.json', 'r', encoding='utf-8') as f:
    lines = f.readlines()
    stations = [json.loads(lines[i]) for i in range(1, len(lines), 2)]

@app.route('/')
def home():
    return "Globe Radio API is running!"

@app.route('/search')
def search():
    query = request.args.get('q', '').strip().lower()
    query_words = query.split()

    if not query_words:
        return jsonify([])

    def match(station):
        text = f"{station.get('name', '')} {station.get('country', '')} {station.get('tags', '')}".lower()
        return all(word in text for word in query_words)

    results = [s for s in stations if match(s)]
    print(f"[SEARCH] Query: '{query}' - Matches: {len(results)}")
    return jsonify(results[:50])

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
