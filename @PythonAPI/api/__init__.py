import json
import threading
import http.client
import socket
import encodings.idna

URL = "127.0.0.1"
PORT = 5001


def hello():
    """
    Returns the classic "Hello world!"
    To execute this function, call:
    ["api.hello", []] call py3_fnc_callExtension
    """
    return "Hello world!"


def get_port():
    return PORT


def send_post_request(playerUID: str, playerName: str, data: dict):
    endpoint = "/bootcamp"
    data = {"playerUID": playerUID, "playerName": playerName, "data": data}
    body = json.dumps(data).encode("utf-8")
    headers = {"Content-Type": "application/json", "Content-Length": len(body)}
    try:
        conn = http.client.HTTPConnection(URL, PORT, timeout=0.1)
        conn.request("POST", endpoint, body, headers)
        conn.getresponse()  # We're not waiting for the response
    except (http.client.HTTPException, socket.timeout):
        pass
    finally:
        conn.close()


def process_nested_data(data):
    if isinstance(data, dict):
        return [[key, process_nested_data(value)] for key, value in data.items()]
    elif isinstance(data, list):
        return [process_nested_data(item) for item in data]
    else:
        return data


def http_request(endpoint: str):
    try:
        conn = http.client.HTTPConnection(URL, PORT)
        conn.request("GET", endpoint)
        response = conn.getresponse()

        if response.status != 200:
            return [["error", f"Could not get data for endpoint {endpoint}"]]
        json_data = json.loads(response.read().decode("utf-8"))
        return [[key, process_nested_data(value)] for key, value in json_data.items()]
    except (http.client.HTTPException, socket.timeout):
        return [["error", f"Could not get data for endpoint {endpoint}"]]
    finally:
        conn.close()


def get_data(playerUID: str):
    endpoint = f"/bootcamp/{playerUID}"
    return http_request(endpoint)


def finish(playerUID: str):
    endpoint = f"/bootcamp/{playerUID}/finished"
    return http_request(endpoint)


def convert_list(lst):
    if len(lst) < 2:
        raise ValueError("Input list has an incorrect format")

    section_name = lst[0]
    key_value_pairs = lst[1]

    res_dct = {section_name: {}}
    for pair in key_value_pairs:
        if len(pair) == 2:
            key, value = pair
            res_dct[section_name][key] = value
        else:
            raise ValueError("Each key-value pair must have exactly 2 elements")

    return res_dct


def add(playerUID: str, playerName: str, data: list):
    post_thread = threading.Thread(
        target=send_post_request, args=(playerUID, playerName, convert_list(data))
    )
    post_thread.start()

    return True

