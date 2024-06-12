import requests
import random
import string
import argparse

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

def write_result(path, dns):
    with open(path, "w") as file:
        file.write(dns)

def create_dns_record(domain_name, record_type, record_content, bearer_token, record_name = None):
    # Get Zone ID
    zone_id = get_zone_id(domain_name, bearer_token)
    if not zone_id:
        return None, None
    
    while True:
        # Generate random record name if not defined
        if record_name is None:
            record_name = generate_random_string()

        if record_type == 'NS':
            record_name = 'ns-'+record_name
            
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
        return full_record_name, response.json()
    else:
        print(f"Failed to create DNS record: {response.status_code}")
        print(response.text)
        return None, None

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Register DNS record with Cloudflare")
    parser.add_argument("--token", help="Cloudflare API token", required=True)
    parser.add_argument("--name", help="Domain name", required=True)
    parser.add_argument("--content", help="Content of the DNS record (IP address or name server)", required=True)
    args = parser.parse_args()
    
    #-- Generating A Record
    full_name_record, is_success = create_dns_record(args.name, 'A', args.content, args.token)

    if is_success:
        write_result('/root/sub_domain.txt', full_name_record)

        ns_record, _ = create_dns_record(args.name, 'NS', full_name_record, args.token, record_name = full_name_record.split('.')[0])
        
        #-- writing result
        write_result('/root/ns.txt', ns_record)

        
        print(f"A Record: {full_name_record}")
        print(f"NS Record: {ns_record}")
    else: 
        raise Exception('Error in Generating DNS Records... executing manual')