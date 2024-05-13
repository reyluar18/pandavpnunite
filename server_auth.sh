#!/bin/bash
. /etc/openvpn/login/config.sh

USERNAME="$1"
PASSWORD="$2"

QUERY="SELECT user_name FROM users WHERE user_name='$USERNAME' AND auth_vpn=md5('$PASSWORD') AND status='live' AND is_freeze=0 AND is_ban=0 AND (duration > 0 OR vip_duration > 0 OR private_duration > 0)"
RESULT=`mysql -u $USER -p$PASS -D $DB -h $HOST -sN -e "$QUERY"`
if [ "$RESULT" != '' ] && [ "$RESULT" = "$USERNAME" ]; then 
    echo "user : $USERNAME"
    echo 'authentication ok.'

    if ! id "$USERNAME" &>/dev/null; then
        sudo useradd -M "$USERNAME"
        echo "$USERNAME:$PASSWORD" | sudo chpasswd
    fi
    
    exit 0
else 
    echo 'authentication failed.'
    exit 1
fi 