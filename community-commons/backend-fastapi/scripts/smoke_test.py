import time
import requests

BASE = "http://127.0.0.1:8000"

def wait_for_server(timeout=30):
    start = time.time()
    while time.time() - start < timeout:
        try:
            r = requests.get(f"{BASE}/api/scenarios")
            if r.status_code < 500:
                return True
        except Exception:
            pass
        time.sleep(1)
    return False


def run():
    print("Waiting for server...")
    if not wait_for_server(30):
        print("Server did not become ready in time.")
        return

    print('\nGET /api/scenarios')
    try:
        r = requests.get(f"{BASE}/api/scenarios")
        print(r.status_code)
        print(r.json())
    except Exception as e:
        print('Error fetching scenarios:', e)

    print('\nPOST /api/players (create)')
    player = {"name": "SmokeTester", "age": 28, "avatar": "test.png"}
    try:
        r = requests.post(f"{BASE}/api/players/", json=player)
        print(r.status_code)
        print(r.json())
        created = r.json()
        player_id = created.get('id') or created.get('player_id') or created.get('player', {}).get('id')
    except Exception as e:
        print('Error creating player:', e)
        player_id = None

    if player_id:
        print(f"Created player id: {player_id}")
    else:
        print("No player id obtained; skipping decision/post tests.")
        return

    print('\nPOST /api/scenarios/<id>/decide (submit decision)')
    try:
        # pick scenario 1 and choice id 1 as a smoke attempt
        payload = {"player_id": player_id, "choice_id": 1}
        r = requests.post(f"{BASE}/api/scenarios/1/decide", json=payload)
        print(r.status_code)
        try:
            print(r.json())
        except Exception:
            print(r.text)
    except Exception as e:
        print('Error submitting decision:', e)

if __name__ == '__main__':
    run()
