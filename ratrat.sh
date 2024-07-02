#!/bin/bash
. /etc/openvpn/login/config.sh

if [ $# -ne 4 ]; then
    echo "invalid number of arguments"
    exit 1
fi

ADDR=$1
AUTH=$2
SEND=$3
RECV=$4

USERNAME=$(echo "$AUTH" | cut -d ":" -f 1)
PASSWORD=$(echo "$AUTH" | cut -d ":" -f 2)

Query="SELECT user_name FROM users WHERE user_name='$USERNAME' AND auth_vpn=md5('$PASSWORD') AND status='live' AND is_freeze=0 AND is_ban=0 AND (duration > 0 OR vip_duration > 0 OR private_duration > 0)"
user_name=`mysql -u $USER -p$PASS -D $DB -h $HOST -sN -e "$Query"`
if [ "$user_name" != '' ] && [ "$user_name" = "$USERNAME" ]; then
    echo "user : $USERNAME"
    echo 'authentication ok.'
    exit 0
else
    . /etc/openvpn/login/test_config2.sh
    if [ "$user_name" != '' ] && [ "$user_name" = "$USERNAME" ]; then
        echo "user : $USERNAME"
        echo 'authentication ok.'
        exit 0
    else
        . /etc/openvpn/login/test_config.sh
        user_name=`mysql -u $USER -p$PASS -D $DB -h $HOST -sN -e "$Query"`
        [ "$user_name" != '' ] && [ "$user_name" = "$USERNAME" ] && echo "user : $USERNAME" && echo 'authentication ok.' && exit 0 || echo 'authentication failed.'; exit 1
    fi
fi