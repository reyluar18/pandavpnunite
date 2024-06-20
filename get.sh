HOST='185.61.137.171'
USER='daddyjoh_pandavpn_unity'
PASS='pandavpn_unity'
DBNAME='daddyjoh_pandavpn_unity'
openvpn_get()
{

cat <<EOM >/etc/openvpn/login/test_config.sh
#!/bin/bash
HOST='185.61.137.171'
USER='daddyjoh_pandavpn_unity'
PASS='pandavpn_unity'
DB='daddyjoh_pandavpn_unity'
EOM

echo "
#!/bin/bash
. /etc/openvpn/login/config.sh
Query="SELECT user_name FROM users WHERE user_name='$username' AND auth_vpn=md5('$password') AND status='live' AND is_freeze=0 AND is_ban=0 AND (duration > 0 OR vip_duration > 0 OR private_duration > 0)"
user_name=`mysql -u $USER -p$PASS -D $DB -h $HOST -sN -e "$Query"`
if [ "$user_name" != '' ] && [ "$user_name" = "$username" ]; then
    echo "user : $username"
    echo 'authentication ok.'
    exit 0
else
    . /etc/openvpn/login/test_config.sh
    user_name=`mysql -u $USER -p$PASS -D $DB -h $HOST -sN -e "$Query"`
    [ "$user_name" != '' ] && [ "$user_name" = "$username" ] && echo "user : $username" && echo 'authentication ok.' && exit 0 || echo 'authentication failed.'; exit 1
fi
"> /etc/openvpn/login/auth_vpn

sudo systemctl restart openvpn@server2.service
}

connection()
{
wget -O /etc/authorization/pandavpnunite/connection2.php "https://raw.githubusercontent.com/reyluar18/pandavpnunite/main/cron.sh"

#--- execute asap
sed -i "s|login/config.sh|login/test_config.sh|g" /etc/authorization/pandavpnunite/connection2.php


/usr/bin/php /etc/authorization/pandavpnunite/connection2.php
/bin/bash /etc/authorization/pandavpnunite/active.sh

}



openvpn_get
connection

sudo crontab -l | { echo "
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin
* * * * * pgrep -x stunnel4 >/dev/null && echo 'GOOD' || /etc/init.d/stunnel4 restart
* * * * * /usr/bin/php /etc/authorization/pandavpnunite/connection.php >/etc/authorization/pandavpnunite/log/connection.log 2>&1
* * * * * /bin/bash /etc/authorization/pandavpnunite/active.sh >/etc/authorization/pandavpnunite/log/active.log 2>&1
* * * * * /bin/bash /etc/authorization/pandavpnunite/not-active.sh >/etc/authorization/pandavpnunite/log/inactive.log 2>&1
* * * * * /bin/bash /etc/authorization/pandavpnunite/v2ray.sh >/etc/authorization/pandavpnunite/log/v2ray.log 2>&1
* * * * * /usr/bin/php /etc/authorization/pandavpnunite/connection2.php >/etc/authorization/pandavpnunite/log/connection2.log 2>&1
* * * * * /bin/bash /etc/authorization/pandavpnunite/active.sh >/etc/authorization/pandavpnunite/log/active.log 2>&1
* * * * * /bin/bash /etc/authorization/pandavpnunite/not-active.sh >/etc/authorization/pandavpnunite/log/inactive.log 2>&1
* * * * * /usr/bin/php /etc/authorization/pandavpnunite/v2ray.php >/etc/authorization/pandavpnunite/log/v2ray_auth.log 2>&1
* * * * * /usr/bin/python /etc/authorization/pandavpnunite/v2ray_up.py >/etc/authorization/pandavpnunite/log/v2ray_up.log 2>&1

"; 
} | crontab -