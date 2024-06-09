import requests
import argparse

def get_zone_id(token, domain_name):
    url = "https://api.cloudflare.com/client/v4/zones"
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json"
    }
    params = {"name": domain_name}
    response = requests.get(url, headers=headers, params=params)
    data = response.json()
    if response.status_code == 200 and data["success"]:
        return data["result"][0]["id"]
    else:
        print("Failed to get zone ID.")
        print(data)
        return None

def register_dns(token, zone_id, subdomain, record_type, content):
    url = f"https://api.cloudflare.com/client/v4/zones/{zone_id}/dns_records"
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json"
    }
    data = {
        "type": record_type,
        "name": subdomain,
        "content": content,
        "proxied": False  # Whether the record is receiving the performance and security benefits of Cloudflare
    }
    response = requests.post(url, headers=headers, json=data)
    print(response.json())
    if response.status_code == 200:
        print("DNS record registered successfully!")
    else:
        print("Failed to register DNS record.")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Register DNS record with Cloudflare")
    parser.add_argument("--token", help="Cloudflare API token", required=True)
    parser.add_argument("--name", help="Domain name", required=True)
    parser.add_argument("--subdomain", help="Subdomain to register", required=True)
    parser.add_argument("--type", help="Type of DNS record (e.g., A, CNAME, NS)", required=True)
    parser.add_argument("--content", help="Content of the DNS record (IP address or name)", required=True)
    args = parser.parse_args()

    zone_id = get_zone_id(args.token, args.name)
    if zone_id:
        register_dns(args.token, zone_id, args.subdomain, args.type, args.content)
