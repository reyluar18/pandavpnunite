import requests
import random
import string

def get_zone_id(domain_name, bearer_token):
    url = "https://api.cloudflare.com/client/v4/zones"
    
    headers = {
        "Authorization": f"Bearer {bearer_token}",
        "Content-Type": "application/json"
    }
    
    params = {
        "name": domain_name,
        "status": "active"
    }
    
    response = requests.get(url, headers=headers, params=params)
    
    if response.status_code == 200:
        zones = response.json().get("result", [])
        if zones:
            return zones[0]["id"]
        else:
            print(f"No active zone found for domain: {domain_name}")
            return None
    else:
        print(f"Failed to fetch zone ID: {response.status_code}")
        print(response.text)
        return None

def dns_record_exists(zone_id, record_type, record_name, bearer_token):
    url = f"https://api.cloudflare.com/client/v4/zones/{zone_id}/dns_records"
    
    headers = {
        "Authorization": f"Bearer {bearer_token}",
        "Content-Type": "application/json"
    }
    
    params = {
        "type": record_type,
        "name": record_name
    }
    
    response = requests.get(url, headers=headers, params=params)
    
    if response.status_code == 200:
        records = response.json().get("result", [])
        if records:
            return True
        else:
            return False
    else:
        print(f"Failed to check DNS records: {response.status_code}")
        print(response.text)
        return None

def generate_random_string(length=8):
    return ''.join(random.choice(string.ascii_lowercase) for _ in range(length))

def create_dns_record(domain_name, record_type, record_content, bearer_token):
    # Get Zone ID
    zone_id = get_zone_id(domain_name, bearer_token)
    if not zone_id:
        return
    
    while True:
        # Generate random record name
        record_name = generate_random_string()
        full_record_name = f"{record_name}.{domain_name}"
        
        # Check if DNS record already exists
        if not dns_record_exists(zone_id, record_type, full_record_name, bearer_token):
            break
        print(f"DNS record {full_record_name} already exists. Generating a new name...")
    
    # Create DNS record
    url = f"https://api.cloudflare.com/client/v4/zones/{zone_id}/dns_records"
    
    headers = {
        "Authorization": f"Bearer {bearer_token}",
        "Content-Type": "application/json"
    }
    
    data = {
        "type": record_type,
        "name": full_record_name,
        "content": record_content,
        "ttl": 1,  # TTL of 1 means automatic
        "proxied": False  # Change to True if you want to use Cloudflare's proxy
    }
    
    response = requests.post(url, headers=headers, json=data)
    
    if response.status_code == 200:
        print(f"DNS record {full_record_name} created successfully")
        return response.json()
    else:
        print(f"Failed to create DNS record: {response.status_code}")
        print(response.text)
        return None

# Example usage
domain_name = "example.com"
record_type = "A"
record_content = "123.123.123.123"
bearer_token = "your_bearer_token_here"

create_dns_record(domain_name, record_type, record_content, bearer_token)
