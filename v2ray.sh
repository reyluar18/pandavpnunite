#!/bin/bash

# Generate JSON array for client credentials
client_array="["
while IFS= read -r line; do
    # Extract the username after -M
    username=$(echo "$line" | awk '{print $(NF)}')

    # Extract the password from the useradd command
    password=$(echo "$line" | awk -F ' -p ' '{print $2}' | awk '{print $(NF)}')

    # Append the username and password to the client array
    client_array+="{'id': '$username', 'alterId': 64, 'security': 'auto', 'password': '$password'}, "
done < active.sh
client_array="${client_array%, }]"  # Remove trailing comma and add closing bracket

# Update V2Ray configuration file with the client array

#echo $client_array
cp /usr/local/etc/v2ray/default-config.json /usr/local/etc/v2ray/config.json
sed -i "s/\"clients\": \[\]/\"clients\": $client_array/" /usr/local/etc/v2ray/config.json