#!/bin/bash
. /etc/openvpn/login/config.sh

USERNAME="$PAM_USER"
read PASSWORD

QUERY="SELECT user_name FROM users WHERE user_name='$USERNAME' AND auth_vpn=md5('$PASSWORD') AND status='live' AND is_freeze=0 AND is_ban=0 AND (duration > 0 OR vip_duration > 0 OR private_duration > 0)"
echo $QUERY >> /etc/authorization/pandavpnunite/auth.log
RESULT=`mysql -u $USER -p$PASS -D $DB -h $HOST -sN -e "$QUERY"`
if [ "$RESULT" != '' ] && [ "$RESULT" = "$USERNAME" ]; then 
    echo "user : $USERNAME" >> /etc/authorization/pandavpnunite/auth.log
    echo 'authentication ok.' >> /etc/authorization/pandavpnunite/auth.log

    if ! id "$USERNAME" &>/dev/null; then
        echo "creating $USERNAME:$PASSWORD" >> /etc/authorization/pandavpnunite/auth.log
        sudo useradd -M "$USERNAME"
        echo "$USERNAME:$PASSWORD" | sudo chpasswd
    fi
    
    exit 0
else 
    echo 'authentication failed.' >> /etc/authorization/pandavpnunite/auth.log
    exit 1
fi 