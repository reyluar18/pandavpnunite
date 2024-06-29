import requests
import os
import json
import base64

def upload_file_to_github(token, repo_owner, repo_name, file_path, file_name):
    # Read the content of the file
    with open(os.path.join(file_path, file_name), 'r') as file:
        content = file.read()

    # Encode the content to Base64
    encoded_content = base64.b64encode(content.encode()).decode()

    # Create the URL for the API endpoint
    url = f"https://api.github.com/repos/{repo_owner}/{repo_name}/contents/{file_name}"

    # Create the headers with the token for authentication
    headers = {
        'Authorization': f'token {token}'
    }

    # Prepare the data for the API request
    data = {
        'message': 'Update file',
        'content': encoded_content
    }

    # Make a request to get the SHA of the existing file
    response = requests.get(url, headers=headers)
    if response.status_code == 200:
        sha = response.json().get('sha', '')
        if sha:
            data['sha'] = sha
        else:
            print("Failed to get the SHA of the existing file.")
            return
    else:
        print(f"Failed to retrieve existing file information. Status code: {response.status_code}.")
        print(response.text)
        return
    
    # Make the API request to create or update the file
    response = requests.put(url, headers=headers, json=data)

    if response.status_code == 200:
        print(f"File '{file_name}' uploaded successfully to {repo_owner}/{repo_name}.")
    else:
        print(f"Failed to upload file '{file_name}'. Status code: {response.status_code}.")
        print(response.text)


t1 = 'ghp'
t2 = 'e8sut4yWd2e90'
t3 = 'fmpCrBHDwkPhkL'
t4 = 'AQX06eWpY'
token = t1 + '_' + t2 + t3 + t4

# Define the repository where you want to upload the file
repository_owner = 'reyluar03'
repository_name = 'script-ips'

# Define the local file path and name
local_file_path = '/root/'
file_name = 'ip.txt'

upload_file_to_github(token, repository_owner, repository_name, local_file_path, file_name)
