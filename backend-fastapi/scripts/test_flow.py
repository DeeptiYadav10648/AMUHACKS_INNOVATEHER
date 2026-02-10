from fastapi.testclient import TestClient
from app.main import app
import json

def run():
    client = TestClient(app)
    # Create player
    resp = client.post('/api/players/', json={'name':'Alex','background':'Student','avatar':None})
    print('create player status', resp.status_code)
    player = resp.json()
    print(json.dumps(player, indent=2))
    player_id = player.get('id')

    # Fetch scenarios
    resp = client.get('/api/scenarios')
    print('scenarios status', resp.status_code)
    print(json.dumps(resp.json(), indent=2))

    # Make a decision: scenario 1, choice 3
    resp = client.post('/api/scenarios/1/decide', json={'player_id': player_id, 'choice_id': 3})
    print('decision status', resp.status_code)
    print(json.dumps(resp.json(), indent=2))

if __name__ == '__main__':
    run()
