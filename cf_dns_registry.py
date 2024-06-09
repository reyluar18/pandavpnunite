import requests

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

def create_dns_record(domain_name, record_type, record_name, record_content, bearer_token):
    # Get Zone ID
    zone_id = get_zone_id(domain_name, bearer_token)
    if not zone_id:
        return
    
    # Create DNS record
    url = f"https://api.cloudflare.com/client/v4/zones/{zone_id}/dns_records"
    
    headers = {
        "Authorization": f"Bearer {bearer_token}",
        "Content-Type": "application/json"
    }
    
    data = {
        "type": record_type,
        "name": f"{record_name}.{domain_name}",
        "content": record_content,
        "ttl": 1,  # TTL of 1 means automatic
        "proxied": False  # Change to True if you want to use Cloudflare's proxy
    }
    
    response = requests.post(url, headers=headers, json=data)
    
    if response.status_code == 200:
        print("DNS record created successfully")
        return response.json()
    else:
        print(f"Failed to create DNS record: {response.status_code}")
        print(response.text)
        return None


create_dns_record(domain_name, record_type, record_name, record_content, bearer_token)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Register DNS record with Cloudflare")
    parser.add_argument("--token", help="Cloudflare API token", required=True)
    parser.add_argument("--name", help="Domain name", required=True)
    parser.add_argument("--subdomain", help="Subdomain to register", required=True)
    parser.add_argument("--type", help="Type of DNS record (e.g., A, CNAME, NS)", required=True)
    parser.add_argument("--content", help="Content of the DNS record (IP address or name server)", required=True)
    args = parser.parse_args()

    create_dns_record(args.name, args.type, args.subdomain, args.content, args.token)