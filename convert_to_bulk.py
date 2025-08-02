import json


input_file = 'stations_raw.json'


output_file = 'bulk_stations.json'

index_name = 'search-radios'

def convert_to_bulk(input_path, output_path):
    with open(input_path, 'r', encoding='utf-8') as f_in, \
            open(output_path, 'w', encoding='utf-8') as f_out:

        stations = json.load(f_in)

        for i, station in enumerate(stations):
            # index komutu satırı
            index_line = json.dumps({"index": {"_index": index_name, "_id": i+1}})
            # istasyon verisi satırı
            data_line = json.dumps(station)
            f_out.write(index_line + '\n')
            f_out.write(data_line + '\n')

if __name__ == '__main__':
    convert_to_bulk(input_file, output_file)
    print(f'Bulk dosyası "{output_file}" oluşturuldu.')
