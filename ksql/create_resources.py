import json
import os
from pathlib import Path

import requests

ROUTE = "http://localhost:8088/ksql"
HEADER = {"content-type": "application/json"}


def call_api_with_statements():
    """
    Function to call the KSQL API to process the ".sql" files located in this same folder
    in order.
    """
    statements = []
    path = Path(__file__).parent
    for file in os.listdir(path):
        if file.endswith(".sql"):
            statements.append(file)

    statements = sorted(statements)

    for file in statements:
        with open(path / file) as f:
            data = f.read()
            content_json = {"ksql": data}
            response = requests.post(url=ROUTE, data=json.dumps(content_json), headers=HEADER)
            response.raise_for_status()


if __name__ == "__main__":
    call_api_with_statements()
    print("KSQL resources created successfully!")
