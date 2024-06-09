import requests

def create_dns_record(zone_id, token, email, record_type, name, content, ttl=120, proxied=False):
    url = f"https://api.cloudflare.com/client/v4/zones/{zone_id}/dns_records"
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json"
    }
    payload = {
        "type": record_type,
        "name": name,
        "content": content,
        "ttl": ttl,
        "proxied": proxied
    }

    response = requests.post(url, headers=headers, json=payload)
    
    if response.status_code == 200:
        return response.json()
    else:
        raise Exception(f"Failed to create DNS record: {response.text}")

# Example usage
zone_id = "your_zone_id"
token = "your_api_token"
email = "your_email"
record_type = "A"  # For example, A, AAAA, CNAME, etc.
name = "subdomain.example.com"
content = "123.123.123.123"  # The IP address for an A record

try:
    result = create_dns_record(zone_id, token, email, record_type, name, content)
    print("DNS record created successfully:", result)
except Exception as e:
    print(e)
