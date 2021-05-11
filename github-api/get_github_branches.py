import requests
import os

# token is personal access token
token = os.getenv('GITHUB_TOKEN', '...')
owner = "Spirent-CIP"
repo = "devops-saltfs"
query_url = f"https://api.github.com/repos/{owner}/{repo}/branches"
headers = {'Authorization': f'token {token}'}
try:
    response = requests.get(query_url, headers=headers)
    response.raise_for_status()
except requests.exceptions.HTTPError as err:
    raise SystemExit(err)

branch_data = response.json()
for branch in branch_data:
    print(branch['name'])
