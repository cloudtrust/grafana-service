# -*- coding: utf-8 -*-
"""Tutorial on using the InfluxDB client."""
# Taken from http://influxdb-python.readthedocs.io/en/latest/examples.html

import argparse
import time
import math

from influxdb import InfluxDBClient


def main(host='localhost', port=80):
    """Instantiate a connection to the InfluxDB."""
    user = 'root'
    password = 'root'
    dbname = 'cloudtrust_grafana_test'
    dbuser = 'jdr'
    dbuser_password = 'jdr'
    query = 'select count(*) from grafana_test;'
    json_body = [
        {
            "measurement": "grafana_test",
            "tags": {
                "region": "Valais"
            },
            "time": "2017-10-10T12:00:00Z",
            "fields": {
                "value": 0.01
            }
        }
    ]
    client = InfluxDBClient(host, port, user, password, dbname)

    print("Create database: " + dbname)
    client.drop_database(dbname)
    client.create_database(dbname)

    print("Create a retention policy")
    client.create_retention_policy('awesome_policy', '3d', 3, default=True)

    print("Switch user: " + dbuser)
    client.switch_user(dbuser, dbuser_password)

    print("Write points:")
    for i in range(0, 628):
        sini = math.sin(i*0.01)
        t = time.localtime()
        # timestamp format: 2017-10-10T12:00:00Z
        timestamp = '{0:d}-{1:d}-{2:d}T{3:02d}:{4:02d}:{5:02d}Z'.format(t[0], t[1], t[2]-1, int(i/60)%24, i%60, 0)
        json_body[0]["time"] = timestamp
        json_body[0]["fields"]["value"] = sini
        client.write_points(json_body)

    print("Querying data: " + query)
    result = client.query(query)

    print("Result: {0}".format(result))

def parse_args():
    """Parse the args."""
    parser = argparse.ArgumentParser(
        description='example code to play with InfluxDB')
    parser.add_argument('--host', type=str, required=False,
                        default='172.17.0.2',
                        help='hostname of InfluxDB http API')
    parser.add_argument('--port', type=int, required=False, default=80,
                        help='port of InfluxDB http API')
    return parser.parse_args()


if __name__ == '__main__':
    args = parse_args()
    main(host=args.host, port=args.port)