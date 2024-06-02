import requests
import argparse

def register_dns(token, domain_name, subdomain, record_type, content):
    url = f"https://api.cloudflare.com/client/v4/zones/{domain_name}/dns_records"
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
    parser.add_argument("--content", help="Content of the DNS record (IP address or name server)", required=True)
    args = parser.parse_args()

    register_dns(args.token, args.name, args.subdomain, args.type, args.content)