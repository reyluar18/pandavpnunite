#!/bin/bash
#Script Variables
#mysql1.blazingfast.io
HOST='185.61.137.171'
USER='daddyjoh_pandavpn_unity'
PASS='pandavpn_unity'
DBNAME='daddyjoh_pandavpn_unity'

rm -rf all_in_one.sh*

#PORT SQUID
PORT_SQUID_1='3128'
PORT_SQUID_2='8080'
PORT_SQUID_3='8181'

#PYTHON PROXY 
PORT_SOCKS='80'
PORT_WEBSOCKET='8081'
PORT_PYPROXY='8010'

#PORT OPENVPN
PORT_OPENVPN='1195';

#SSL
PORT_OPENVPN_SSL='443'
PORT_DROPBEAR_SSL='444'
PORT_SSH_SSL='445'

#OTHERS
PORT_DROPBEAR='442'
PORT_HYSTERIA='5666'
PORT_DNSTT='5300'

timedatectl set-timezone Asia/Manila
server_ip=$(curl -s https://api.ipify.org)
server_interface=$(ip route get 8.8.8.8 | awk '/dev/ {f=NR} f&&NR-1==f' RS=" ")

echo -e " \033[0;35m══════════════════════════════════════════════════════════════════\033[0m"
echo '#############################################
#         Authentication file system        #
#       Setup by: Pandavpn Unite            #
#       Server System: Panda VPN 	        #
#            owner: Pandavpnunite      	    #
#############################################'
echo -e " \033[0;35m══════════════════════════════════════════════════════════════════\033[0m"
read -p "Please enter ns host for Slowdns: " NS
# NS="ns-sg.kathropavpn.store"

echo $NS > /root/ns.txt


install_require () {

dnf update -y
dnf install -y epel-release
dnf install -y curl wget cronie unzip
dnf install -y iptables-services
sudo yum install snapd
sudo systemctl enable --now snapd.socket
sudo ln -s /var/lib/snapd/snap /snap
dnf install -y openvpn nc php-cli neofetch vnstat php-mysqlnd
sudo snap install http
dnf install -y screen squid stunnel dropbear gnutls-utils python3
dnf install -y dos2unix nano unzip jq virt-what net-tools mysql
dnf install -y mlocate rpm-build audit-libs-devel gcc make fail2ban
mkdir -p /etc/update-motd.d
dnf install -y inxi figlet
dnf install -y lsof git iptables-services firewalld
snap install lolcat
# git clone git://github.com/KittyKatt/screenFetch.git screenfetch
# cp screenfetch/screenfetch-dev /usr/bin/screenfetch
# chmod +x /usr/bin/screenfetch


clear
}


install_hysteria(){
clear
echo 'Installing hysteria.'
{
wget -N --no-check-certificate -q -O ~/hysteria.sh https://raw.githubusercontent.com/reyluar18/pandavpnunite/main/hysteria.sh; chmod +x ~/hysteria.sh; ./hysteria.sh --version v1.3.5

rm -f /etc/hysteria/config.json

echo '{
  "listen": ":PORT_HYSTERIA",
  "cert": "/etc/hysteria/server.crt",
  "key": "/etc/hysteria/server.key",
  "up_mbps": 100,
  "down_mbps": 100,
  "disable_udp": false,
  "obfs": "pandavpnunite",
  "auth": {
    "mode": "external",
    "config": {
    "cmd": "./.auth.sh"
    }
  },
  "prometheus_listen": ":5665",
}
' >> /etc/hysteria/config.json


cat <<"EOM" >/etc/hysteria/.auth.sh
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
[ "$user_name" != '' ] && [ "$user_name" = "$USERNAME" ] && echo "user : $username" && echo 'authentication ok.' && exit 0 || echo 'authentication failed.'; exit 1
EOM

sed -i "s|PORT_HYSTERIA|$PORT_HYSTERIA|g" /etc/hysteria/config.json
chmod 755 /etc/hysteria/config.json
touch /etc/hysteria/logs
sysctl -w net.core.rmem_max=16777216
sysctl -w net.core.wmem_max=16777216

#-- monitoring 
wget -O /etc/hysteria/monitor.sh "https://raw.githubusercontent.com/reyluar18/pandavpnunite/main/hysteria/monitor.sh"
wget -O /etc/hysteria/online.sh "https://raw.githubusercontent.com/reyluar18/pandavpnunite/main/hysteria/online.sh"

chmod +x /etc/hysteria/monitor.sh
chmod +x /etc/hysteria/online.sh

wget -O /usr/bin/badvpn-udpgw "https://raw.githubusercontent.com/reyluar18/pandavpnunite/main/badvpn-udpgw64"
chmod +x /usr/bin/badvpn-udpgw
ps x | grep 'udpvpn' | grep -v 'grep' || screen -dmS udpvpn /usr/bin/badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 10000 --max-connections-for-client 10 --client-socket-sndbuf 10000
} &>/dev/null
}

setup_ssl() {
#Creating Hysteria CERT
cat << EOF > /etc/hysteria/server.crt
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number: 1 (0x1)
        Signature Algorithm: sha256WithRSAEncryption
        Issuer: C=PH, ST=MA, L=Antipolo City, O=TKNetwork, OU=TKNerwork, CN=TKNetwork CA/name=TKNetwork/emailAddress=ericlaylay@gmail.com
        Validity
            Not Before: Sep 20 03:54:08 2022 GMT
            Not After : Sep 17 03:54:08 2032 GMT
        Subject: C=PH, ST=CA, L=Antipolo City, O=TKNetwork, OU=TKNerwork, CN=TKNetwork/name=TKNetwork/emailAddress=ericlaylay@gmail.com
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                RSA Public-Key: (2048 bit)
                Modulus:
                    00:b5:eb:a1:de:45:39:54:a9:12:db:91:b0:68:ac:
                    77:39:7e:4d:ee:5c:ae:6c:2f:57:a7:70:a6:19:39:
                    19:b0:46:75:6d:50:81:9d:3c:43:5a:21:49:84:b1:
                    fa:68:67:2e:05:ba:ec:e1:08:3b:70:07:77:32:03:
                    19:65:7c:af:d5:10:97:8a:3a:af:11:66:ee:42:b2:
                    90:b5:1a:34:28:55:76:0f:a3:ac:f3:e9:1d:fc:d7:
                    5f:7c:89:50:3b:7e:0f:49:61:97:b7:79:b5:c6:29:
                    2a:c5:e3:ef:38:43:77:12:cb:06:d0:e1:2c:4a:38:
                    fe:0a:33:ec:2c:b7:79:bf:b9:fa:d7:ea:2c:9f:02:
                    4f:10:eb:0a:6f:05:5a:50:01:dc:50:93:71:03:b9:
                    63:34:53:9e:30:9d:23:64:66:e8:9c:73:19:85:39:
                    b6:79:b4:55:1d:9d:2a:e0:df:4c:b2:5a:c2:e9:0e:
                    59:a2:3a:70:34:6a:9c:8a:09:34:1d:5e:29:a9:b6:
                    5b:16:ce:9e:c5:6c:50:d6:4d:10:09:60:f6:c9:00:
                    81:29:e3:a1:4c:10:fb:fe:a5:14:d6:b5:2a:e0:72:
                    50:2f:50:dc:bc:34:8d:ca:e2:fb:78:06:4d:b5:cd:
                    fe:9a:cd:2a:b7:c9:79:32:66:4a:bf:d3:d0:04:25:
                    9e:d5
                Exponent: 65537 (0x10001)
        X509v3 extensions:
            X509v3 Basic Constraints: 
                CA:FALSE
            Netscape Cert Type: 
                SSL Server
            Netscape Comment: 
                Easy-RSA Generated Server Certificate
            X509v3 Subject Key Identifier: 
                28:1D:A2:5E:3A:50:2C:3A:E0:B0:54:57:D6:11:02:FC:D6:1F:FF:35
            X509v3 Authority Key Identifier: 
                keyid:DB:6B:D9:7E:CC:36:11:1E:67:E8:45:B0:07:26:88:17:F6:8B:F3:AB
                DirName:/C=PH/ST=MA/L=Antipolo City/O=TKNetwork/OU=TKNerwork/CN=TKNetwork CA/name=TKNetwork/emailAddress=ericlaylay@gmail.com
                serial:52:67:60:3D:A2:29:17:35:5F:CA:B9:4A:8E:E2:80:74:F3:CE:64:EB

            X509v3 Extended Key Usage: 
                TLS Web Server Authentication
            X509v3 Key Usage: 
                Digital Signature, Key Encipherment
            X509v3 Subject Alternative Name: 
                DNS:[server]
    Signature Algorithm: sha256WithRSAEncryption
         0c:5a:d1:93:48:73:de:35:f0:1b:b5:88:71:be:ce:04:e0:f7:
         c3:b1:ef:48:05:2f:20:ff:68:6c:e6:10:0f:d2:65:6b:57:e4:
         cc:36:af:4c:ec:d4:0c:46:4c:76:5a:7d:20:74:92:67:41:5f:
         74:27:3b:48:39:51:65:ff:86:3b:1b:6a:15:b1:11:99:45:cd:
         03:0e:e2:46:5d:c0:19:e0:07:0c:18:1e:6e:a1:f6:f2:32:b5:
         3d:91:27:0a:e8:ae:e5:22:a0:f1:87:9f:b8:ba:d8:eb:6b:2b:
         82:8d:e4:2e:66:0a:2a:1f:f6:bb:ee:6a:92:8f:c7:77:0d:ee:
         68:96:58:ce:52:c5:6a:c5:7a:24:fd:ee:83:ba:0b:4e:28:b6:
         92:60:f1:ce:24:bc:9e:a5:ca:73:d3:cc:69:48:a4:8b:31:c3:
         7f:41:d1:31:2d:1e:e8:c7:4f:5d:d6:c1:e8:8d:b7:44:49:0a:
         5a:6c:ea:44:a3:70:19:12:2d:a9:d1:90:bd:3a:3d:4b:85:c0:
         35:d0:03:94:1f:de:68:1c:a0:5d:f0:b9:6c:40:68:97:1a:25:
         c1:5a:a0:cc:a9:51:68:d5:37:be:74:e4:23:0a:fd:74:92:54:
         9e:2f:fc:65:56:d1:27:3b:05:01:b4:c1:b4:a9:10:8d:70:30:
         a0:b6:74:55
-----BEGIN CERTIFICATE-----
MIIFazCCBFOgAwIBAgIBATANBgkqhkiG9w0BAQsFADCBqjELMAkGA1UEBhMCUEgx
CzAJBgNVBAgTAk1BMRYwFAYDVQQHEw1BbnRpcG9sbyBDaXR5MRIwEAYDVQQKEwlU
S05ldHdvcmsxEjAQBgNVBAsTCVRLTmVyd29yazEVMBMGA1UEAxMMVEtOZXR3b3Jr
IENBMRIwEAYDVQQpEwlUS05ldHdvcmsxIzAhBgkqhkiG9w0BCQEWFGVyaWNsYXls
YXlAZ21haWwuY29tMB4XDTIyMDkyMDAzNTQwOFoXDTMyMDkxNzAzNTQwOFowgacx
CzAJBgNVBAYTAlBIMQswCQYDVQQIEwJDQTEWMBQGA1UEBxMNQW50aXBvbG8gQ2l0
eTESMBAGA1UEChMJVEtOZXR3b3JrMRIwEAYDVQQLEwlUS05lcndvcmsxEjAQBgNV
BAMTCVRLTmV0d29yazESMBAGA1UEKRMJVEtOZXR3b3JrMSMwIQYJKoZIhvcNAQkB
FhRlcmljbGF5bGF5QGdtYWlsLmNvbTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCC
AQoCggEBALXrod5FOVSpEtuRsGisdzl+Te5crmwvV6dwphk5GbBGdW1QgZ08Q1oh
SYSx+mhnLgW67OEIO3AHdzIDGWV8r9UQl4o6rxFm7kKykLUaNChVdg+jrPPpHfzX
X3yJUDt+D0lhl7d5tcYpKsXj7zhDdxLLBtDhLEo4/goz7Cy3eb+5+tfqLJ8CTxDr
Cm8FWlAB3FCTcQO5YzRTnjCdI2Rm6JxzGYU5tnm0VR2dKuDfTLJawukOWaI6cDRq
nIoJNB1eKam2WxbOnsVsUNZNEAlg9skAgSnjoUwQ+/6lFNa1KuByUC9Q3Lw0jcri
+3gGTbXN/prNKrfJeTJmSr/T0AQlntUCAwEAAaOCAZswggGXMAkGA1UdEwQCMAAw
EQYJYIZIAYb4QgEBBAQDAgZAMDQGCWCGSAGG+EIBDQQnFiVFYXN5LVJTQSBHZW5l
cmF0ZWQgU2VydmVyIENlcnRpZmljYXRlMB0GA1UdDgQWBBQoHaJeOlAsOuCwVFfW
EQL81h//NTCB6gYDVR0jBIHiMIHfgBTba9l+zDYRHmfoRbAHJogX9ovzq6GBsKSB
rTCBqjELMAkGA1UEBhMCUEgxCzAJBgNVBAgTAk1BMRYwFAYDVQQHEw1BbnRpcG9s
byBDaXR5MRIwEAYDVQQKEwlUS05ldHdvcmsxEjAQBgNVBAsTCVRLTmVyd29yazEV
MBMGA1UEAxMMVEtOZXR3b3JrIENBMRIwEAYDVQQpEwlUS05ldHdvcmsxIzAhBgkq
hkiG9w0BCQEWFGVyaWNsYXlsYXlAZ21haWwuY29tghRSZ2A9oikXNV/KuUqO4oB0
885k6zATBgNVHSUEDDAKBggrBgEFBQcDATALBgNVHQ8EBAMCBaAwEwYDVR0RBAww
CoIIW3NlcnZlcl0wDQYJKoZIhvcNAQELBQADggEBAAxa0ZNIc9418Bu1iHG+zgTg
98Ox70gFLyD/aGzmEA/SZWtX5Mw2r0zs1AxGTHZafSB0kmdBX3QnO0g5UWX/hjsb
ahWxEZlFzQMO4kZdwBngBwwYHm6h9vIytT2RJwroruUioPGHn7i62OtrK4KN5C5m
Ciof9rvuapKPx3cN7miWWM5SxWrFeiT97oO6C04otpJg8c4kvJ6lynPTzGlIpIsx
w39B0TEtHujHT13WweiNt0RJClps6kSjcBkSLanRkL06PUuFwDXQA5Qf3mgcoF3w
uWxAaJcaJcFaoMypUWjVN7505CMK/XSSVJ4v/GVW0Sc7BQG0wbSpEI1wMKC2dFU=
-----END CERTIFICATE-----
EOF

cat << EOF > /etc/hysteria/server.key
-----BEGIN PRIVATE KEY-----
MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQC166HeRTlUqRLb
kbBorHc5fk3uXK5sL1encKYZORmwRnVtUIGdPENaIUmEsfpoZy4FuuzhCDtwB3cy
AxllfK/VEJeKOq8RZu5CspC1GjQoVXYPo6zz6R381198iVA7fg9JYZe3ebXGKSrF
4+84Q3cSywbQ4SxKOP4KM+wst3m/ufrX6iyfAk8Q6wpvBVpQAdxQk3EDuWM0U54w
nSNkZuiccxmFObZ5tFUdnSrg30yyWsLpDlmiOnA0apyKCTQdXimptlsWzp7FbFDW
TRAJYPbJAIEp46FMEPv+pRTWtSrgclAvUNy8NI3K4vt4Bk21zf6azSq3yXkyZkq/
09AEJZ7VAgMBAAECggEBALI+EPcKtEVy8vsXH9UvRhGa4xhszqlJKYTxJo0IGVdR
cbSNcLFyXjts6e+Nwl+Q2NLcd0N1IWd+qRbjWnrJVC5ad2AEZ4uRYlkPRCFtbzUl
putj3w2Mlsko7HHEyEvCE5A+grxOD//8TeBemAB0ebJ8Ik1+kjqW5LFydjDKBAwI
sYjXpYGkMST9rqG82EToQn9jL5Ncby35Ls3owzWDfd/1Y4NQmk6gO09spoMzWJpS
mSiV+w83QxxJtOgT00O9NuDz9skotW3v2xWTZue0BzMirCTQWPiFRL1476/O9KYD
KUBAcWynC/PE4ub0lMfaesdrggjRoDYvaQp3xLx/6HECgYEA4siN9t7Ogwhf/4X7
BAN+2OSRWRW8tn9wzzNAPzhjs8igm4W+C4lQtMmW9eFOHuRj6TiWp4w36m4cs5VF
eK39mp3/nyd9l68bFjGxw3XZsI/5bTGgcrSVAAAGp65xadI3+1Ozy7OmFoRF/Gkv
X7+/DyWz5nb9yAH/N69vPpVek8sCgYEAzVt4qpMc5tX6tMxCAC1ZUFo8fwSZndmk
jDTgb2G2O1YIqrYHqVjtwMQiDxvBGdkVJuy8QQQHM6YCD3o1Jq56bjvY1IlumXCW
0YeKfSeqfXN/nBCkyZxa79DkQSPeYEjFTFABVe/SEEcasn8HrlyygtFT+nLCcEz/
V1ekP5Mmg98CgYEApsGOEh9XfuZjoIKmRxdC6L15WyYus4sWKmWnMlWGiqZV4sX/
LoB0BdvN01MunGyYQt/Hd8AVRZ5eIHb8tHZL6quPUTo6kZTCuBkme3Fm9vuHDxHU
x0Od5HggbKBK6OMZIwczR+/7iscMp0O5ABEArmSs2iRZC/7b6dhoVn6DIu0CgYA+
tOvHylxM8JI5mxWcUDyxmJxYfOMbnFXuqkbOPBwVSlQjLKpyP8F512o/Cs6QQgV/
eVKS19QLJWoDp+GLCkRAXO39GGo5WHP1T1oulWouHJKe6UYoeiIakMLiUT2aUR5O
CzAdObn/VncEgl2qFIw9/gWSuHA/MoPV++EfuKNOKQKBgDbyYfG3JESaLpaEiPED
UQDv4iVBzaqA3sMpmpA2YRIUZE4ZzSuiVMxGHfhAvueuiMwyzqsLe0BOgCNtJDg3
o4CmMhs3Wlw5FiOru1LxQY//65wi5q8+rNF4DR3oUKoVGb1PD3Gm8ZsxirhMOCrc
sKKWTJk08giHse+yqTKQ05uR
-----END PRIVATE KEY-----
EOF

chmod 755 /etc/hysteria/config.json
chmod 755 /etc/hysteria/server.crt
chmod 755 /etc/hysteria/server.key


}



install_dropbear() {
/bin/cat <<"EOM" >/etc/update-motd.d/01-custom
#!/bin/sh

exec 2>&1

# lolcat MIGHT NOT BE IN $PATH YET, SO BE EXPLICIT
LOLCAT=/usr/games/lolcat

# UPPERCASE HOSTNAME, APPLY FIGLET FONT "block" AND CENTERING
INFO_HOST=$(echo PANDA-UNITE | awk '{print toupper($0)}' | figlet -tc -f block)

# RUN IT ALL THROUGH lolcat FOR COLORING
printf "%s\n%s\n" "$INFO_HOST" | $LOLCAT -f
EOM

chmod -x /etc/update-motd.d/*
chmod +x /etc/update-motd.d/01-custom
rm -f /etc/motd
touch /etc/motd.tail

sed -i 's/NO_START=1/NO_START=0/g' /etc/sysconfig/dropbear
sed -i "s|DROPBEAR_PORT=22|DROPBEAR_PORT=$PORT_DROPBEAR|g" /etc/sysconfig/dropbear
echo "/bin/false" >> /etc/shells
echo "/usr/sbin/nologin" >> /etc/shells
systemctl restart dropbear
}

install_websocket_and_socks(){
echo "Installing websocket and socks"
{
    wget --no-check-certificate https://raw.githubusercontent.com/reyluar18/pandavpnunite/main/websocket.py -O /usr/local/sbin/websocket.py
    dos2unix /usr/local/sbin/websocket.py
    chmod +x /usr/local/sbin/websocket.py

    wget --no-check-certificate https://raw.githubusercontent.com/reyluar18/pandavpnunite/main/proxy.py -O /usr/local/sbin/proxy.py
    dos2unix /usr/local/sbin/proxy.py
    chmod +x /usr/local/sbin/proxy.py
}&>/dev/null
}

install_dnstt(){

echo "Installing DNSTT"
{
cd /usr/local
wget https://golang.org/dl/go1.16.2.linux-amd64.tar.gz
tar xvf go1.16.2.linux-amd64.tar.gz

export GOROOT=/usr/local/go
export PATH=$GOPATH/bin:$GOROOT/bin:$PATH
cd /root
git config --global http.sslverify false
git clone https://github.com/NuclearDevilStriker/dnstt.git
cd /root/dnstt/dnstt-server
go build
./dnstt-server -gen-key -privkey-file server.key -pubkey-file server.pub

cat <<EOM > /root/dnstt/dnstt-server/server.key
124d51aed2abceb984978cfe73bbfaa1b74ec0be869510ac254efc6e9ec7addc
EOM

cat <<EOM > /root/dnstt/dnstt-server/server.pub
5d30d19aa2524d7bd89afdffd9c2141575b21a728ea61c8cd7c8bf3839f97032
EOM
echo $NS > /root/ns.txt
NSNAME="$(cat /root/ns.txt)"
cd /root/dnstt/dnstt-server
screen -dmS slowdns-server ./dnstt-server -udp :$PORT_DNSTT -privkey-file server.key $NSNAME 127.0.0.1:22

cd /root/dnstt/dnstt-client
go build
cp /root/dnstt/dnstt-server/server.pub /root/dnstt/dnstt-client/server.pub
screen -dmS slowdns-client ~/dnstt/dnstt-client/dnstt-client -dot 1.1.1.1:853 -pubkey-file ~/dnstt/dnstt-client/server.pub $NSNAME 127.0.0.1:2222

cat <<EOM > /bin/dnsttauto.sh
sudo kill $( sudo lsof -i:$PORT_DNSTT -t )
nsname="$(cat /root/ns.txt)"
cd /root/dnstt/dnstt-server
screen -dmS slowdns-server ~/dnstt/dnstt-server/dnstt-server -udp :$PORT_DNSTT -privkey-file ~/dnstt/dnstt-server/server.key $nsname 127.0.0.1:22
screen -dmS slowdns-client ~/dnstt/dnstt-client/dnstt-client -dot 1.1.1.1:853 -pubkey-file ~/dnstt/dnstt-client/server.pub $NSNAME 127.0.0.1:2222

EOM
}&>/dev/null


}

execute_to_screen(){
    
cat <<EOM >/root/auto
#!/bin/bash

if nc -z localhost PORT_WEBSOCKET; then
    echo "WebSocket is running"
else
    echo "Starting WebSocket"
    screen -dmS websocket python /usr/local/sbin/websocket.py PORT_WEBSOCKET
fi

if nc -z localhost PORT_PYPROXY; then
    echo "Python Proxy Running"
else
    echo "Starting Port PORT_PYPROXY"
    screen -dmS proxy python /usr/local/sbin/proxy.py PORT_PYPROXY
fi
EOM
sed -i "s|PORT_WEBSOCKET|$PORT_WEBSOCKET|g" /root/auto
sed -i "s|PORT_PYPROXY|$PORT_PYPROXY|g" /root/auto

bash /root/auto
}


install_squid(){
clear
echo 'Installing proxy.'
{
    service squid stop
    squid -z
    cd /etc/squid/
    rm squid.conf
    echo "acl PandaVPNUnite dst `curl -s https://api.ipify.org`" >> squid.conf
    echo 'http_port SQUID_PORT_1
http_port SQUID_PORT_2
http_port SQUID_PORT_3
visible_hostname Proxy
acl PURGE method PURGE
acl HEAD method HEAD
acl POST method POST
acl GET method GET
acl CONNECT method CONNECT
http_access allow PandaVPNUnite
http_reply_access allow all
http_access deny all
icp_access allow all
always_direct allow all
visible_hostname PandaVPNUnite-Proxy
error_directory /usr/share/squid/errors/English' >> squid.conf
sed -i "s|SQUID_PORT_1|$PORT_SQUID_1|g" squid.conf
sed -i "s|SQUID_PORT_2|$PORT_SQUID_2|g" squid.conf
sed -i "s|SQUID_PORT_3|$PORT_SQUID_3|g" squid.conf
mkdir -p /usr/share/squid/errors/English
cd /usr/share/squid/errors/English
rm -rf ERR_INVALID_URL
echo '<!--PandaVPNUnite--><!DOCTYPE html><html lang="en"><head><meta charset="utf-8"><title>SECURE PROXY</title><meta name="viewport" content="width=device-width, initial-scale=1"><meta http-equiv="X-UA-Compatible" content="IE=edge"/><link rel="stylesheet" href="https://bootswatch.com/4/slate/bootstrap.min.css" media="screen"><link href="https://fonts.googleapis.com/css?family=Press+Start+2P" rel="stylesheet"><style>body{font-family: "Press Start 2P", cursive;}.fn-color{color: #ffff; background-image: -webkit-linear-gradient(92deg, #f35626, #feab3a); -webkit-background-clip: text; -webkit-text-fill-color: transparent; -webkit-animation: hue 5s infinite linear;}@-webkit-keyframes hue{from{-webkit-filter: hue-rotate(0deg);}to{-webkit-filter: hue-rotate(-360deg);}}</style></head><body><div class="container" style="padding-top: 50px"><div class="jumbotron"><h1 class="display-3 text-center fn-color">SECURE PROXY</h1><h4 class="text-center text-danger">SERVER</h4><p class="text-center">😍 %w 😍</p></div></div></body></html>' >> ERR_INVALID_URL
chmod 755 *
systemctl start squid
cd /etc || exit
wget 'https://raw.githubusercontent.com/reyluar18/pandavpnunite/main/socks_3.py' -O /etc/socks.py
dos2unix /etc/socks.py
chmod +x /etc/socks.py
 }&>/dev/null
}


install_openvpn()
{
clear
echo "Installing openvpn."
{
mkdir -p /etc/openvpn/easy-rsa/keys
mkdir -p /etc/openvpn/login
mkdir -p /etc/openvpn/server
mkdir -p /var/www/html/stat
touch /etc/openvpn/server.conf
touch /etc/openvpn/server2.conf

echo 'DNS=1.1.1.1
DNSStubListener=no' >> /etc/systemd/resolved.conf

echo '#Openvpn Configuration by PandaVPNUnite Developer :)
dev tun
port PORT_OPENVPN
proto udp
server 10.10.0.0 255.255.0.0
ca /etc/openvpn/easy-rsa/keys/ca.crt
cert /etc/openvpn/easy-rsa/keys/server.crt
key /etc/openvpn/easy-rsa/keys/server.key
dh /etc/openvpn/easy-rsa/keys/dh.pem
ncp-disable
tls-server
tls-version-min 1.2
tls-cipher TLS-ECDHE-RSA-WITH-AES-128-GCM-SHA256
cipher AES-128-GCM
auth SHA256
persist-key
persist-tun
ping-timer-rem
compress lz4-v2
keepalive 10 120
reneg-sec 86400
user nobody
group nogroup
client-to-client
duplicate-cn
username-as-common-name
verify-client-cert none
script-security 3
auth-user-pass-verify "/etc/openvpn/login/auth_vpn" via-env #
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
push "compress lz4-v2"
push "persist-key"
push "persist-tun"
client-connect /etc/openvpn/login/connect.sh
client-disconnect /etc/openvpn/login/disconnect.sh
log /etc/openvpn/server/udpserver.log
status /etc/openvpn/server/udpclient.log
status-version 2
verb 3' > /etc/openvpn/server.conf

sed -i "s|PORT_OPENVPN|$PORT_OPENVPN|g" /etc/openvpn/server.conf

echo '#Openvpn Configuration by PandaVPNUnite Developer :)
dev tun
port PORT_OPENVPN
proto tcp
server 10.20.0.0 255.255.0.0
ca /etc/openvpn/easy-rsa/keys/ca.crt
cert /etc/openvpn/easy-rsa/keys/server.crt
key /etc/openvpn/easy-rsa/keys/server.key
dh /etc/openvpn/easy-rsa/keys/dh.pem
ncp-disable
tls-server
tls-version-min 1.2
tls-cipher TLS-ECDHE-RSA-WITH-AES-128-GCM-SHA256
cipher AES-128-GCM
auth SHA256
persist-key
persist-tun
ping-timer-rem
compress lz4-v2
keepalive 10 120
reneg-sec 86400
user nobody
group nogroup
client-to-client
duplicate-cn
username-as-common-name
verify-client-cert none
script-security 3
auth-user-pass-verify "/etc/openvpn/login/auth_vpn" via-env #
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
push "compress lz4-v2"
push "persist-key"
push "persist-tun"
client-connect /etc/openvpn/login/connect.sh
client-disconnect /etc/openvpn/login/disconnect.sh
log /etc/openvpn/server/tcpserver.log
status /etc/openvpn/server/tcpclient.log
status-version 2
verb 3' > /etc/openvpn/server2.conf

sed -i "s|PORT_OPENVPN|$PORT_OPENVPN|g" /etc/openvpn/server2.conf

cat <<EOM >/etc/openvpn/login/config.sh
#!/bin/bash
HOST='DBHOST'
USER='DBUSER'
PASS='DBPASS'
DB='DBNAME'
EOM

sed -i "s|DBHOST|$HOST|g" /etc/openvpn/login/config.sh
sed -i "s|DBUSER|$USER|g" /etc/openvpn/login/config.sh
sed -i "s|DBPASS|$PASS|g" /etc/openvpn/login/config.sh
sed -i "s|DBNAME|$DBNAME|g" /etc/openvpn/login/config.sh

wget -O /etc/openvpn/login/auth_vpn "https://raw.githubusercontent.com/reyluar18/pandavpnunite/main/auth_vpn"

#client-connect file
wget -O /etc/openvpn/login/connect.sh "https://raw.githubusercontent.com/reyluar18/pandavpnunite/main/connect"

sed -i "s|SERVER_IP|$server_ip|g" /etc/openvpn/login/connect.sh

#TCP client-disconnect file
wget -O /etc/openvpn/login/disconnect.sh "https://raw.githubusercontent.com/reyluar18/pandavpnunite/main/disconnect"

sed -i "s|SERVER_IP|$server_ip|g" /etc/openvpn/login/disconnect.sh


cat << EOF > /etc/openvpn/easy-rsa/keys/ca.crt
-----BEGIN CERTIFICATE-----
MIIDOTCCAiGgAwIBAgIUSZAv6F72cr0UTp8buhWP2+Fhr8kwDQYJKoZIhvcNAQEL
BQAwEDEOMAwGA1UEAwwFcGFuZGEwHhcNMjQwNTE5MDAxNDQ4WhcNMzQwNTE3MDAx
NDQ4WjAQMQ4wDAYDVQQDDAVwYW5kYTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCC
AQoCggEBANkLYo4JoqaoYmdHJt57diUwRpeXiP/zHhBkX6RRZw+Al0/1ucG9X5rl
njgEGDhRVFC1mrbI/eAsBByoz49ZkE984WTayUEjXc23cFmzyGfa/u0RiZIzG7Pz
yaoC4g1kzupgjVG5lGYWdLHebBLkGkoZZoWAHkhcv67lNb1WhqLngb9Wo6zD7qhf
u11cQ61zyHVJo3sWVEL9kJqA5poh0AJe22rGGUbUB95XBdniDJSPRLYOOGICU+P6
OqTbTDIoxQBv/xg4euR5jVYLwO/UGZo9ZY0H301EEs28mJLfkF4qWKD24ao8uRjt
2f6jAYsTcAK6dEMMTzFYdXRqe+Lvam8CAwEAAaOBijCBhzAdBgNVHQ4EFgQUd36F
uMxxTSGGLBr9i2GFXlaL09wwSwYDVR0jBEQwQoAUd36FuMxxTSGGLBr9i2GFXlaL
09yhFKQSMBAxDjAMBgNVBAMMBXBhbmRhghRJkC/oXvZyvRROnxu6FY/b4WGvyTAM
BgNVHRMEBTADAQH/MAsGA1UdDwQEAwIBBjANBgkqhkiG9w0BAQsFAAOCAQEAknve
v7783QjUUHJm7dfggWyaMwvvkPR3PzwiRHs5fk5JKyETtD1bYKugPblAsLl/W3p3
kOan8VRMxwf/rVrvnjSZbcGz4sjg7DnvbKFtGSjm2fJUJgwUU2d4cDK1BldFR09y
PZBU036tpL9FcZINsOYZJd1ZGVbb1X59R90qroP1VCaf2NFQREMDj67Sx5k4ceWE
NcEQIXWXEARMO9q3ZACgOn4xSjGCf/I40YCD6WF2a5Nm1szJGTdd/dF86tRFo9G/
J9dAWeEWXRugBiyqOjAaUzWoQIrLKExaI9CQRxzANT55uTLVJ3teqYfxM4WoGSkr
d+JAaHx+Pkx/X4ucXg==
-----END CERTIFICATE-----
EOF

cat << EOF > /etc/openvpn/easy-rsa/keys/server.crt
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            d3:a0:08:6f:e1:e9:4d:e3:ac:d6:ae:b9:4d:52:f9:9a
        Signature Algorithm: sha256WithRSAEncryption
        Issuer: CN=panda
        Validity
            Not Before: May 19 00:16:39 2024 GMT
            Not After : May  4 00:16:39 2027 GMT
        Subject: CN=panda
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                RSA Public-Key: (2048 bit)
                Modulus:
                    00:ca:4a:03:4e:b2:c6:18:b8:49:df:1b:f3:d5:e7:
                    1e:bc:b0:54:2b:70:86:50:3e:57:54:24:d9:22:96:
                    71:e5:77:f7:ca:7d:d1:2a:26:40:f0:61:92:0c:17:
                    2d:32:8b:a4:f4:36:c3:20:e6:5b:ea:ed:b6:74:d0:
                    76:24:1d:e8:d4:1e:62:de:16:2c:3e:fe:52:5e:b1:
                    a9:74:40:76:87:cb:24:88:28:b3:91:1a:96:cc:21:
                    43:41:64:2f:71:99:64:f4:99:14:c3:e6:4d:69:3e:
                    bb:2a:6f:f5:96:9d:ae:eb:03:99:a4:ae:4d:1d:7e:
                    a0:cc:cc:26:e0:67:fa:06:1f:ee:19:54:ec:f7:da:
                    b2:0f:d3:94:fd:0c:15:cb:7a:17:cf:32:ea:8f:52:
                    3a:65:a5:6c:54:c9:4d:af:9f:8a:fa:7a:7b:f0:76:
                    fa:99:9a:7a:15:a6:f0:60:6d:25:3e:4c:34:dd:79:
                    ac:25:49:3f:f6:8b:22:43:76:48:59:9c:88:ee:8e:
                    99:7b:3f:63:5e:eb:2b:27:60:23:83:a1:ee:4e:9b:
                    f7:79:b1:62:22:58:52:bf:d9:e4:ce:83:65:3e:b5:
                    d9:34:e3:8c:f6:1e:bc:ba:66:90:8b:3d:e2:e3:16:
                    cd:86:5a:89:c1:aa:69:68:cb:ec:bf:8a:54:e5:38:
                    82:87
                Exponent: 65537 (0x10001)
        X509v3 extensions:
            X509v3 Basic Constraints:
                CA:FALSE
            X509v3 Subject Key Identifier:
                A1:66:DD:FE:8A:EF:3A:49:8A:FB:B6:CF:7F:0A:64:2B:72:21:34:B6
            X509v3 Authority Key Identifier:
                keyid:77:7E:85:B8:CC:71:4D:21:86:2C:1A:FD:8B:61:85:5E:56:8B:D3:DC
                DirName:/CN=panda
                serial:49:90:2F:E8:5E:F6:72:BD:14:4E:9F:1B:BA:15:8F:DB:E1:61:AF:C9

            X509v3 Extended Key Usage:
                TLS Web Server Authentication
            X509v3 Key Usage:
                Digital Signature, Key Encipherment
            X509v3 Subject Alternative Name:
                DNS:panda
    Signature Algorithm: sha256WithRSAEncryption
         1e:f1:ba:c2:7c:a0:cb:9a:71:ef:c2:ab:9f:f8:4a:fd:b0:a1:
         be:3a:50:9c:5b:8f:55:66:49:ef:c1:28:30:c7:83:ce:0a:67:
         75:19:dc:d8:d3:ec:ab:2b:54:39:19:3c:1e:ec:72:0a:5d:47:
         d4:99:2a:d0:24:f9:1c:b2:34:2f:49:82:28:3f:73:15:56:83:
         47:78:8e:4f:db:b6:64:5d:6e:4e:c5:8a:5e:b9:c0:a8:11:7c:
         12:a2:56:2d:ce:b4:69:30:05:b3:09:77:ec:ea:93:23:76:6d:
         7d:42:6a:64:70:c5:06:df:63:4e:b1:73:b9:d2:58:30:a7:57:
         23:ef:3a:d4:38:7a:29:9e:64:e8:3b:cc:90:46:47:5c:3a:4c:
         4b:3c:fe:aa:10:12:7b:d9:dd:3a:23:0e:bb:75:50:fc:ab:c1:
         7f:7f:e1:22:a3:f2:ed:2b:09:de:64:cc:e5:62:2d:96:b2:bd:
         85:88:c1:b3:b3:34:41:05:43:64:56:c3:e9:7c:25:02:78:c3:
         4f:ae:9c:65:46:d7:73:b0:78:ce:fd:ac:9f:78:9a:bf:35:af:
         a2:c4:59:48:76:d7:74:96:c6:ac:cb:db:4c:82:08:67:44:4f:
         ed:87:d2:52:b6:8b:4e:31:59:1e:fc:9e:7e:eb:2f:9b:0e:d2:
         a3:79:30:1c
-----BEGIN CERTIFICATE-----
MIIDWjCCAkKgAwIBAgIRANOgCG/h6U3jrNauuU1S+ZowDQYJKoZIhvcNAQELBQAw
EDEOMAwGA1UEAwwFcGFuZGEwHhcNMjQwNTE5MDAxNjM5WhcNMjcwNTA0MDAxNjM5
WjAQMQ4wDAYDVQQDDAVwYW5kYTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoC
ggEBAMpKA06yxhi4Sd8b89XnHrywVCtwhlA+V1Qk2SKWceV398p90SomQPBhkgwX
LTKLpPQ2wyDmW+rttnTQdiQd6NQeYt4WLD7+Ul6xqXRAdofLJIgos5EalswhQ0Fk
L3GZZPSZFMPmTWk+uypv9ZadrusDmaSuTR1+oMzMJuBn+gYf7hlU7Pfasg/TlP0M
Fct6F88y6o9SOmWlbFTJTa+fivp6e/B2+pmaehWm8GBtJT5MNN15rCVJP/aLIkN2
SFmciO6OmXs/Y17rKydgI4Oh7k6b93mxYiJYUr/Z5M6DZT612TTjjPYevLpmkIs9
4uMWzYZaicGqaWjL7L+KVOU4gocCAwEAAaOBrjCBqzAJBgNVHRMEAjAAMB0GA1Ud
DgQWBBShZt3+iu86SYr7ts9/CmQrciE0tjBLBgNVHSMERDBCgBR3foW4zHFNIYYs
Gv2LYYVeVovT3KEUpBIwEDEOMAwGA1UEAwwFcGFuZGGCFEmQL+he9nK9FE6fG7oV
j9vhYa/JMBMGA1UdJQQMMAoGCCsGAQUFBwMBMAsGA1UdDwQEAwIFoDAQBgNVHREE
CTAHggVwYW5kYTANBgkqhkiG9w0BAQsFAAOCAQEAHvG6wnygy5px78Krn/hK/bCh
vjpQnFuPVWZJ78EoMMeDzgpndRnc2NPsqytUORk8HuxyCl1H1Jkq0CT5HLI0L0mC
KD9zFVaDR3iOT9u2ZF1uTsWKXrnAqBF8EqJWLc60aTAFswl37OqTI3ZtfUJqZHDF
Bt9jTrFzudJYMKdXI+861Dh6KZ5k6DvMkEZHXDpMSzz+qhASe9ndOiMOu3VQ/KvB
f3/hIqPy7SsJ3mTM5WItlrK9hYjBs7M0QQVDZFbD6XwlAnjDT66cZUbXc7B4zv2s
n3iavzWvosRZSHbXdJbGrMvbTIIIZ0RP7YfSUraLTjFZHvyefusvmw7So3kwHA==
-----END CERTIFICATE-----
EOF

cat << EOF > /etc/openvpn/easy-rsa/keys/server.key
-----BEGIN PRIVATE KEY-----
MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDKSgNOssYYuEnf
G/PV5x68sFQrcIZQPldUJNkilnHld/fKfdEqJkDwYZIMFy0yi6T0NsMg5lvq7bZ0
0HYkHejUHmLeFiw+/lJesal0QHaHyySIKLORGpbMIUNBZC9xmWT0mRTD5k1pPrsq
b/WWna7rA5mkrk0dfqDMzCbgZ/oGH+4ZVOz32rIP05T9DBXLehfPMuqPUjplpWxU
yU2vn4r6envwdvqZmnoVpvBgbSU+TDTdeawlST/2iyJDdkhZnIjujpl7P2Ne6ysn
YCODoe5Om/d5sWIiWFK/2eTOg2U+tdk044z2Hry6ZpCLPeLjFs2GWonBqmloy+y/
ilTlOIKHAgMBAAECggEADoKinBmMxicp/VwG8JgEh2pqjzciG01tfDascKO0Bc7G
Mns17r0RuWx2SnG7Jz4HFhF7i7eabk6g4N43Kz4N/nEzjFSw1c/uXqaFzjX1iqYS
t8Wbo9PxbzEPnvgtwwtKx5TXfXneoacDS/b9+dDTxD3c3og2NeBobmhSfZRXxeqR
uvhhQcp9pMYgCSqHXp1JVWSUF1Ck49oWjlZebG4ROukpYaj1HNt7kQZYOnR+cjYc
bniDbAM19wSQRN5SvTsoHAzav2MjB2CIp1eFrmHqVB8MLmxbsNak3pjfHimI1BX4
rPTLu3cwSqV/BOQd+BwzezdGS02jSQQ9RanUwY7HKQKBgQDwHUxJ/89Px4pUx3aY
QMVxaD0+g1TXMvNdsHHOb9PcRdoSU8iSaDRhYp28eLTfV84DiZK/xRX2uP5Aq6jn
lQ6Ze9KXLCHJBHVVq4ZDiuUta3SRG3/Wl4rW7ntIVaMPMrQmml/D62IaiN0Zcr94
0arD2bfxXZldbIv7lYhT5tniKwKBgQDXrBXpXzLlSlBJO7Tv5IXt3dfNtO2jbf/2
VMjxZqadt2HvXe3Ohtzzsh1yYK7NkUrqAzNU51OwXlva0RzZ9TCUDxS6y2RDy0N1
wYu6gsCG1a7DItxsYeM6SyX98o0SmJHbZTsMY/De3fUyyUCPMexcC1ko/vHPqpdG
SO75yMFfFQKBgGNcvGUi5rcs66GJqRn4M7xqVm24CzPCcdMjYPT8cb+FaGiNI0Ly
vDpQhNWpXa/OtgHgvEl/VUdz5kL8xjiPBiudgdfs+04j+iopgLYSlCPng6VIq+4x
Z9LpfTrBtWhkowgWeeqpTT+Nw3D0eyeUHAZP4j6PbResA4For7GIpkFhAoGAcVi8
j1D8A6thtItPlYBJrvCXeUHsXqbyDfkTPmOPj3YQX2fDEnaoat8iQLl1RQ5mC8Sw
1p9YyWld5wtdmWMWK8odP+qjAEo0Yw/cKqKLIpHs7htFMyTi8gEKr4MpByvuBBsY
xHNF5StLsWw5pMg9C0bfjf8nANgL9uFfzyDmF90CgYEAjDGVTd552rNoVkQhbE6Y
ME/tA9SOKIrvNR7/hwb2bRWAAARNVDrkStgQ+cdyXkz4xlg8EdrpYW+pOXxtTZko
AjxI9f2Hu+BmW8QontVniptXq3LoPS3PTR5fvZDQ3dODKhopWcoTp4Qllw4JiXj6
Ka8U7BHpoCKbDt0sJRAJymo=
-----END PRIVATE KEY-----
EOF

cat << EOF > /etc/openvpn/easy-rsa/keys/dh.pem
-----BEGIN DH PARAMETERS-----
MIIBCAKCAQEA0z+K5yZ+9NWeZvnlw0IZqzFRKFQBZkzIekWWbAfSr0hgsHfnzQ2B
33ywD/puT9ahdkZZgfZP/MMgQ2mct6ftgAoqOwDntkDFc8m+EDEe/HCFFKPVXD3O
de/ysx81US/DhS7LO8pW3HIAOLU729TpsdkuLGtogVCSrRSuc6Wqj7Y9XDVT98UH
2z2iDRQGKd04TZ0Y3nLH5m0QZUPHasxwmDe+SQbbbAhJfj1U68B88umfoyKzeA6r
ZFK1z/GOti1szoRNZF5KVHy9qiNi8zSD76ffqB8QwbOS2A4zeRvBXbyQ5XU9g8nL
PjgSqmT0XJICJrWuXf1v4MfZfm6Mgl66awIBAg==
-----END DH PARAMETERS-----
EOF

dos2unix /etc/openvpn/login/auth_vpn
dos2unix /etc/openvpn/login/connect.sh
dos2unix /etc/openvpn/login/disconnect.sh

chmod 777 -R /etc/openvpn/
chmod 755 /etc/openvpn/server.conf
chmod 755 /etc/openvpn/server2.conf
chmod 755 /etc/openvpn/login/connect.sh
chmod 755 /etc/openvpn/login/disconnect.sh
chmod 755 /etc/openvpn/login/config.sh
chmod 755 /etc/openvpn/login/auth_vpn
}&>/dev/null
}


install_firewall_kvm () {
clear
echo "Installing iptables."
{
# Adjust sysctl configuration
echo "net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.default.accept_source_route = 0
kernel.sysrq = 0
kernel.core_uses_pid = 1
net.ipv4.tcp_syncookies = 1
kernel.msgmnb = 65536
kernel.msgmax = 65536
kernel.shmmax = 68719476736
kernel.shmall = 4294967296
net.ipv4.ip_forward = 1
fs.file-max = 65535
net.core.rmem_default = 262144
net.core.rmem_max = 262144
net.core.wmem_default = 262144
net.core.wmem_max = 262144
net.ipv4.tcp_rmem = 4096 87380 8388608
net.ipv4.tcp_wmem = 4096 65536 8388608
net.ipv4.tcp_mem = 4096 4096 4096
net.ipv4.tcp_low_latency = 1
net.core.netdev_max_backlog = 4000
net.ipv4.ip_local_port_range = 1024 65000
net.ipv4.tcp_max_syn_backlog = 16384" > /etc/sysctl.conf

sysctl -p

# Adjust firewall rules using firewalld
# You may need to install firewalld if it's not installed already: sudo dnf install firewalld
sudo systemctl enable firewalld
sudo systemctl restart firewalld

firewall-cmd --zone=public --permanent --add-port=53/udp
firewall-cmd --zone=public --permanent --add-port=5300/udp
firewall-cmd --zone=public --permanent --add-port=20100-20900/udp
firewall-cmd --reload

mkdir -p /etc/iptables/

iptables-save > /etc/iptables/rules.v4
ip6tables-save > /etc/iptables/rules.v6
iptables-save > /etc/iptables_rules.v4
ip6tables-save > /etc/iptables_rules.v6

}&>/dev/null
}



install_stunnel() {
  {
cd /etc/stunnel/ || exit

echo "-----BEGIN RSA PRIVATE KEY-----
MIIEpgIBAAKCAQEAzg+mGfSfOqC7p3C8NYBNQkoaLuYnjIBK+48pTWkZ8FbmypxG
bk78J6vPLeqHCvY7iKOCSbAFLQSmRB5ltaOuO1gYeogefIzAFA8EPamI6m483Y+X
Fh44Xoud9M4B3qydeNYqmmkTC1tM26eYNhixk9lYQtvYDR13h2BXQZ3bMUZx6/69
7QNYghvbaKt7z0HSF+AV+zEb8t0M0Jmwe7B9Qz74ujBw10eY60Oh10QHrN7fiR0U
lVZpeu6XLibkUmvuY/8yZy9XEg/QV9LjbsmACqwL1pS2ExzbBR2HeNV8fckepYvw
PAMdzygeN9ZGj445HltmdBTVMFJXN3vmpWtKSQIDAQABAoIBAQDFReoJM041fKfq
t10YA0rzyamjeKgoNLKUfwxVledFVo0BL/elp2x0NmHUXZEHh5CbUZ5sGV37KVZc
JJXO/XLSUZatyB8XslA5Y971gZcYiI0wuEU24ZupuBRyx762hZ8EjlSfGzUmTDQa
nip0r9Nh7lQ3Pe1rMOi77BndMdklI8eg0PGB9DNDnGPjsatkn6X5TakAYvV5G+kV
/PjWyOubBIjuN4qWF57loeh6MWOpm9O33EipBlcK26pn6cS/R/QkI4b3hbeoGJoz
FohkLjwncq4PGdIgUtMppRZF9KXec8QIlCLNYOENAfJmJwVqioft8kBM2ykjoM+z
8MwhqZjZAoGBAP+8DJZsMZ6WrsPu3bRQ8ylF0J+a0EVzUBASAwFFiOFtVKWyr3Wm
zFROLz0LcuVHtTs3OiGRS75wbrnUUB3+bCyj08pHk0HSMYx/OdroeY+TFCi9IPjg
9WzFD0sLjcLKmEBNLN/shpKnNQImj5ampUIYsBoUe7OV4P+UvsreCKg7AoGBAM5G
Zqi4Mmn05MQb2MRTcc/haV9bFRPIWBMOMW9XT7lDJEmy61lJ2fL63z6c/CPor5sV
ZLjX1SsSphlhbWvVSA1dVQUwzQY4AjoJ3ggY75Je7/TIrlFMaQraxpzOHazw1gh5
2DlHFzr9HJM3lVrt3RTayRUySSBu4fmVgCAidvNLAoGBAIPzbG9E3glc6EnSevRp
/D0kd7OSdroO+JWCJajHTww5lD52xw+mg7FQMhGGUb8506n9IfJl/LYDXy5k/P2s
4/XYhhPOAI4qvUQn9RsdbnOFSRaIF3Yy5I890lk/WeLTE+HBsFDNwtXyjmhQqy/p
RkWnZV3ficAsqk5VWmhkTgU3AoGBAJcw+uYHvMv0+AjV8FhWYUFhkv6VoClT21p8
OLfHY2QDVoG+ZsqXWuzB/QfDwPwA/VXKpHznlhNwI9bOlolHVvyUwFCBqIU6YEdy
HBALVu4OMAtXXI2yV/vgx1r/qLit/fNQe6/f76MJCvzM7OgtGLLEekbTCM6A95kc
f0EOgelpAoGBAKWAC/z4n8GQSJ+mDkVf1gmT9i2uuyCwzHDUZwpoSlGCQf2qZKjD
6lFyflt60poPRw0yTkyrv9TqdCxfmmK/o+jJp/j8A7qFYt5mcSUvwj3hkvGKdqY9
oAjmT6yneiARd3KhLIftp4Fo48vNzU3RLqkk1rrWoaBDvK7lhzkNIEmD
-----END RSA PRIVATE KEY-----
-----BEGIN CERTIFICATE-----
MIIEDzCCAvegAwIBAgIUVrhI9GNGuQIoDwV7uPLsYPsbVN0wDQYJKoZIhvcNAQEL
BQAwgZYxCzAJBgNVBAYTAlBIMQ8wDQYDVQQIDAZBbmdvbm8xDjAMBgNVBAcMBVJp
emFsMRgwFgYDVQQKDA9QYW5kYSBWUE4gVW5pdGUxETAPBgNVBAsMCFBBTkRBVlBO
MREwDwYDVQQDDAhQQU5EQVZQTjEmMCQGCSqGSIb3DQEJARYXcGFuZGF2cG51bml0
ZUBnbWFpbC5jb20wHhcNMjQwNTE1MTUxNDAyWhcNMjcwNTE1MTUxNDAyWjCBljEL
MAkGA1UEBhMCUEgxDzANBgNVBAgMBkFuZ29ubzEOMAwGA1UEBwwFUml6YWwxGDAW
BgNVBAoMD1BhbmRhIFZQTiBVbml0ZTERMA8GA1UECwwIUEFOREFWUE4xETAPBgNV
BAMMCFBBTkRBVlBOMSYwJAYJKoZIhvcNAQkBFhdwYW5kYXZwbnVuaXRlQGdtYWls
LmNvbTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAM4Pphn0nzqgu6dw
vDWATUJKGi7mJ4yASvuPKU1pGfBW5sqcRm5O/Cerzy3qhwr2O4ijgkmwBS0EpkQe
ZbWjrjtYGHqIHnyMwBQPBD2piOpuPN2PlxYeOF6LnfTOAd6snXjWKpppEwtbTNun
mDYYsZPZWELb2A0dd4dgV0Gd2zFGcev+ve0DWIIb22ire89B0hfgFfsxG/LdDNCZ
sHuwfUM++LowcNdHmOtDoddEB6ze34kdFJVWaXruly4m5FJr7mP/MmcvVxIP0FfS
427JgAqsC9aUthMc2wUdh3jVfH3JHqWL8DwDHc8oHjfWRo+OOR5bZnQU1TBSVzd7
5qVrSkkCAwEAAaNTMFEwHQYDVR0OBBYEFPLfHhq3zC0HHxHP/i4l9O4+LxyrMB8G
A1UdIwQYMBaAFPLfHhq3zC0HHxHP/i4l9O4+LxyrMA8GA1UdEwEB/wQFMAMBAf8w
DQYJKoZIhvcNAQELBQADggEBAG+h/f5V8XTnMj0+foayN/WbVv1FS6mnfwDxY6hi
BqDetXSXV0kcfF9i2RX8NYjgYI/7mHEITgG+XVw0wIJ389zkER8p+EldAvgYBvfz
Vos09yRGACyV4MDWY1Zc0VaWiYHz4Wq72u6UmAqu7TPISuifTPmK/C6+bdAJKhEF
x+GF1SxqdSmNJDD4+VSc+/POrLk5teS70kMgRgRYf12J3OSftXtY2A4J93ZlhlRA
DwR9nm2zeljwuH9aKgw+BPiQ8ZVKMoJLJ/Khmkaxj4v7Q6mwegkjXh+UwBmk9RtT
f3hqH8xsT0xyX6kKg+id/rzjeHyCcWcNoodoCF2IzovhbgA=
-----END CERTIFICATE-----" > stunnel.pem
rm -f stunnel.conf
mkdir -p /usr/local/var/run/
echo "debug = 0
output = /tmp/stunnel.log
cert = /etc/stunnel/stunnel.pem
pid = /usr/local/var/run/stunnel.pid
client = no
socket = a:SO_REUSEADDR=1
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1

[sshd]
accept = PORT_SSH_SSL
connect = 127.0.0.1:22
[dropbear]
accept = PORT_DROPBEAR_SSL
connect = 127.0.0.1:PORT_DROPBEAR
[openvpn]
connect = PORT_OPENVPN  
accept = PORT_OVPN_SSL 

" >> stunnel.conf

sed -i "s|PORT_OPENVPN|$PORT_OPENVPN|g" /etc/stunnel/stunnel.conf
sed -i "s|PORT_SSH_SSL|$PORT_SSH_SSL|g" /etc/stunnel/stunnel.conf
sed -i "s|PORT_DROPBEAR_SSL|$PORT_DROPBEAR_SSL|g" /etc/stunnel/stunnel.conf
sed -i "s|PORT_DROPBEAR|$PORT_DROPBEAR|g" /etc/stunnel/stunnel.conf
sed -i "s|PORT_OVPN_SSL|$PORT_OPENVPN_SSL|g" /etc/stunnel/stunnel.conf

cd /etc/default && rm stunnel

echo 'ENABLED=1
FILES="/etc/stunnel/*.conf"
OPTIONS=""
PPP_RESTART=0
RLIMITS=""' >> stunnel

chmod 755 stunnel
sudo service stunnel restart
  } &>/dev/null
}


install_rclocal(){
  {
sed -i 's/Listen 80/Listen 81/g' /etc/httpd/conf/httpd.conf
systemctl restart httpd

    
sudo systemctl restart stunnel
sudo systemctl enable openvpn-server@server.service
sudo systemctl start openvpn-server@server.service
sudo systemctl enable openvpn-server@server2.service
sudo systemctl start openvpn-server@server2.service
 
    
    echo "[Unit]
Description=pandavpnunite service

[Service]
Type=oneshot
ExecStart=/bin/bash /etc/rc.local
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target" >> /etc/systemd/system/pandavpnunite.service
    echo '#!/bin/sh -e
service ufw stop
iptables-restore < /etc/iptables_rules.v4
ip6tables-restore < /etc/iptables_rules.v6
sysctl -p
service stunnel restart
systemctl restart openvpn@server.service
systemctl restart openvpn@server2.service
screen -dmS socks python /etc/socks.py 80
ps x | grep 'udpvpn' | grep -v 'grep' || screen -dmS udpvpn /usr/bin/badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 10000 --max-connections-for-client 10 --client-socket-sndbuf 10000
bash /etc/hysteria/monitor.sh openvpn
bash /etc/hysteria/online.sh
exit 0' >> /etc/rc.local
    sudo chmod +x /etc/rc.local
    systemctl daemon-reload
    sudo systemctl enable pandavpnunite
    sudo systemctl start pandavpnunite.service
    
    mkdir -p -m 777 /root/.web
echo "Installation success: Pandavpnunite... " > /root/.web/index.php

( set -o posix ; set ) | grep PORT > /root/.ports
sed -i "s|$PORT_DNSTT|$PORT_DNSTT > SLOWCHAVE KEY = 5d30d19aa2524d7bd89afdffd9c2141575b21a728ea61c8cd7c8bf3839f97032 > NAMESERVER = $(cat /root/ns.txt)|g" /root/.ports

  }&>/dev/null
}


install_require
install_hysteria
setup_ssl
install_squid
install_openvpn
install_firewall_kvm
install_stunnel