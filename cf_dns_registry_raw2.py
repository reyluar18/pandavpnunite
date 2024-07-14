import requests
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
            return True, records[0]["id"]  # Return True and record ID if record exists
        else:
            return False, None
    else:
        print(f"Failed to check DNS records: {response.status_code}")
        print(response.text)
        return None, None

def is_dns_alive(cname):
    url = f"http://{cname}:5623/server_info.txt"
    try:
        response = requests.get(url, timeout=5)
        if response.status_code == 200:
            return True
        else:
            return False
    except requests.RequestException as e:
        return False

def write_result(path, dns):
    with open(path, "w") as file:
        file.write(dns)

def create_dns_record(domain_name, record_type, record_content, bearer_token, record_name):

    # Get Zone ID
    zone_id = get_zone_id(domain_name, bearer_token)
    if not zone_id:
        return None, None
    
    full_record_name = f"{record_name}.{domain_name}"
    
    # Check if DNS record already exists
    record_exists, record_id = dns_record_exists(zone_id, record_type, full_record_name, bearer_token)
    
    if record_exists:
        # print("record exists")
        # Update DNS record
        url = f"https://api.cloudflare.com/client/v4/zones/{zone_id}/dns_records/{record_id}"
        headers = {
            "Authorization": f"Bearer {bearer_token}",
            "Content-Type": "application/json"
        }
        data = {
            "type": record_type,
            "name": full_record_name,
            "content": record_content,
            "ttl": 1,
            "proxied": False
        }
        response = requests.put(url, headers=headers, json=data)
        
        if response.status_code == 200:
            print(f"DNS record {full_record_name} updated successfully")
            return full_record_name, True
        else:
            print(f"Failed to update DNS record: {response.status_code}")
            print(response.text)
            return None, False
    else:
        # print("record not exists")
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
            "ttl": 1,
            "proxied": False
        }
        
        response = requests.post(url, headers=headers, json=data)
        
        if response.status_code == 200:
            # print(f"DNS record {full_record_name} created successfully")
            return full_record_name, True
        else:
            print(f"Failed to create DNS record: {response.status_code}")
            print(response.text)
            return None, False

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Register DNS record with Cloudflare")
    parser.add_argument("--token", help="Cloudflare API token", required=True)
    parser.add_argument("--name", help="Domain name", required=True)
    parser.add_argument("--content", help="Content of the DNS record (IP address or name server)", required=True)
    args = parser.parse_args()
    
    # Read existing DNS server names from dns.txt
    dns_servers = 10
    with open("/root/dns_count.txt", "r") as f:
        dns_servers = int(f.read())
    
    # Try each DNS server until one is found that is not alive
    success = False
    for dns_server in range(1, dns_servers+1):
        dns_server = f"server{dns_server}.{args.name}"
        if is_dns_alive(dns_server):
            print(f"DNS server {dns_server} is alive. Trying the next one...")
        else:
            dns_server = dns_server.split('.')[0]

            # Create or update CNAME record
            full_cname_record, is_cname_success = create_dns_record(args.name, 'A', args.content, args.token, dns_server)
            
            if is_cname_success:
                write_result('/root/sub_domain.txt', full_cname_record)
                print(f"A Record: {full_cname_record}")
                
                # Create or update NS record
                ns_record_name = "ns-"+dns_server
                ns_record_content = f"{full_cname_record}"
                full_ns_record, is_ns_success = create_dns_record(args.name, 'NS', ns_record_content, args.token, ns_record_name)
                
                if is_ns_success:
                    write_result('/root/ns.txt', full_ns_record)
                    print(f"NS Record: {full_ns_record}")
                    
                    success = True
                    break  # Exit the loop if NS record creation/update was successful
                else:
                    print("Error in creating/updating NS record... manual intervention needed")
                    break
            else:
                print("Error in creating/updating CNAME record... manual intervention needed")
                break
    
    if not success:
        raise Exception("Unable to create/update DNS records for any available DNS server")
