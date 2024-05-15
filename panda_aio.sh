#!/bin/bash
#Script Variables
HOST='185.61.137.171'
USER='daddyjoh_pandavpn_unity'
PASS='pandavpn_unity'
DBNAME='daddyjoh_pandavpn_unity'

rm -rf install_server.sh*
rm -rf panda_aio.sh*

#PORT OPENVPN
PORT_TCP='1194';
PORT_UDP='53';

timedatectl set-timezone Asia/Manila
server_ip=$(curl -s https://api.ipify.org)
server_interface=$(ip route get 8.8.8.8 | awk '/dev/ {f=NR} f&&NR-1==f' RS=" ")

echo -e " \033[0;35m══════════════════════════════════════════════════════════════════\033[0m"
echo '#############################################
#         Authentication file system        #
#       Setup by: Pandavpn Unite            #
#       Server System: Panda VPN 	        #
#            owner: Pandavpnunite      	    #
#############################################                      
 '
echo -e " \033[0;35m══════════════════════════════════════════════════════════════════\033[0m"

install_require () {

export DEBIAN_FRONTEND=noninteractive
apt update
apt install -y curl wget cron python-minimal libpython-stdlib
apt install -y iptables
apt install -y openvpn netcat httpie php neofetch vnstat
apt install -y screen squid stunnel4 dropbear gnutls-bin python
apt install -y dos2unix nano unzip jq virt-what net-tools default-mysql-client
apt install -y mlocate dh-make libaudit-dev build-essential fail2ban
#clear
#}&>/dev/null
clear
}

install_squid(){
clear
echo 'Installing proxy.'
{
sudo cp /etc/apt/sources.list /etc/apt/sources.list_backup
echo "deb http://deb.debian.org/debian bullseye main contrib non-free
deb-src http://deb.debian.org/debian bullseye main contrib non-free
deb http://deb.debian.org/debian bullseye-updates main contrib non-free
deb-src http://deb.debian.org/debian bullseye-updates main contrib non-free
deb http://deb.debian.org/debian bullseye-backports main contrib non-free
deb-src http://deb.debian.org/debian bullseye-backports main contrib non-free
deb http://security.debian.org/debian-security/ bullseye-security main contrib non-free
deb-src http://security.debian.org/debian-security/ bullseye-security main contrib non-free" >> /etc/apt/sources.list
    apt update
    apt install -y gcc-4.9 g++-4.9
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.9 10
    update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-4.9 10
    update-alternatives --install /usr/bin/cc cc /usr/bin/gcc 30
    update-alternatives --set cc /usr/bin/gcc
    update-alternatives --install /usr/bin/c++ c++ /usr/bin/g++ 30
    update-alternatives --set c++ /usr/bin/g++
    cd /usr/src
    wget https://raw.githubusercontent.com/freenetsapinas/ymod/main/squid-3.1.23.tar.gz
    tar zxvf squid-3.1.23.tar.gz
    cd squid-3.1.23
    ./configure --prefix=/usr \
      --localstatedir=/var/squid \
      --libexecdir=/usr/lib/squid \
      --srcdir=. \
      --datadir=/usr/share/squid \
      --sysconfdir=/etc/squid \
      --with-default-user=proxy \
      --with-logdir=/var/log/squid \
      --with-pidfile=/var/run/squid.pid
    make -j$(nproc)
    make install
    wget --no-check-certificate -O /etc/init.d/squid https://raw.githubusercontent.com/freenetsapinas/ymod/main/squid.sh
    chmod +x /etc/init.d/squid
    update-rc.d squid defaults
    chown -cR proxy /var/log/squid
    squid -z
    cd /etc/squid/
    rm squid.conf
    echo "acl Michaele dst `curl -s https://api.ipify.org`" >> squid.conf
    echo 'http_port 8080
http_port 8181
visible_hostname Proxy
acl PURGE method PURGE
acl HEAD method HEAD
acl POST method POST
acl GET method GET
acl CONNECT method CONNECT
http_access allow Michaele
http_reply_access allow all
http_access deny all
icp_access allow all
always_direct allow all
visible_hostname Michaele-Proxy
error_directory /usr/share/squid/errors/English' >> squid.conf
    cd /usr/share/squid/errors/English
    rm ERR_INVALID_URL
    echo '<!--MichaeleAbalos--><!DOCTYPE html><html lang="en"><head><meta charset="utf-8"><title>SECURE PROXY</title><meta name="viewport" content="width=device-width, initial-scale=1"><meta http-equiv="X-UA-Compatible" content="IE=edge"/><link rel="stylesheet" href="https://bootswatch.com/4/slate/bootstrap.min.css" media="screen"><link href="https://fonts.googleapis.com/css?family=Press+Start+2P" rel="stylesheet"><style>body{font-family: "Press Start 2P", cursive;}.fn-color{color: #ffff; background-image: -webkit-linear-gradient(92deg, #f35626, #feab3a); -webkit-background-clip: text; -webkit-text-fill-color: transparent; -webkit-animation: hue 5s infinite linear;}@-webkit-keyframes hue{from{-webkit-filter: hue-rotate(0deg);}to{-webkit-filter: hue-rotate(-360deg);}}</style></head><body><div class="container" style="padding-top: 50px"><div class="jumbotron"><h1 class="display-3 text-center fn-color">SECURE PROXY</h1><h4 class="text-center text-danger">SERVER</h4><p class="text-center">😍 %w 😍</p></div></div></body></html>' >> ERR_INVALID_URL
    chmod 755 *
    /etc/init.d/squid start
cd /etc || exit
wget 'https://raw.githubusercontent.com/freenetsapinas/ymod/main/socks.py' -O /etc/socks.py
dos2unix /etc/socks.py
chmod +x /etc/socks.py
rm /etc/apt/sources.list
sudo cp /etc/apt/sources.list_backup /etc/apt/sources.list
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

echo '#Openvpn Configuration by YModified Developer :)
dev tun
port PORT_UDP
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
cipher none
auth none
persist-key
persist-tun
ping-timer-rem
compress lz4-v2
keepalive 10 120
reneg-sec 86400
user nobody
group nogroup
client-to-client
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

sed -i "s|PORT_UDP|$PORT_UDP|g" /etc/openvpn/server.conf

echo '#Openvpn Configuration by YModified Developer :)
dev tun
port PORT_TCP
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
cipher none
auth none
persist-key
persist-tun
ping-timer-rem
compress lz4-v2
keepalive 10 120
reneg-sec 86400
user nobody
group nogroup
client-to-client
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

sed -i "s|PORT_TCP|$PORT_TCP|g" /etc/openvpn/server2.conf

cat <<\EOM >/etc/openvpn/login/config.sh
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

wget -O /etc/openvpn/login/auth_vpn "https://raw.githubusercontent.com/freenetsapinas/ymod/main/premium"

#client-connect file
wget -O /etc/openvpn/login/connect.sh "https://raw.githubusercontent.com/freenetsapinas/ymod/main/connect"

sed -i "s|SERVER_IP|$server_ip|g" /etc/openvpn/login/connect.sh

#TCP client-disconnect file
wget -O /etc/openvpn/login/disconnect.sh "https://raw.githubusercontent.com/freenetsapinas/ymod/main/disconnect"

sed -i "s|SERVER_IP|$server_ip|g" /etc/openvpn/login/disconnect.sh


cat << EOF > /etc/openvpn/easy-rsa/keys/ca.crt
-----BEGIN CERTIFICATE-----
MIIFBDCCA+ygAwIBAgIUUmdgPaIpFzVfyrlKjuKAdPPOZOswDQYJKoZIhvcNAQEL
BQAwgaoxCzAJBgNVBAYTAlBIMQswCQYDVQQIEwJNQTEWMBQGA1UEBxMNQW50aXBv
bG8gQ2l0eTESMBAGA1UEChMJVEtOZXR3b3JrMRIwEAYDVQQLEwlUS05lcndvcmsx
FTATBgNVBAMTDFRLTmV0d29yayBDQTESMBAGA1UEKRMJVEtOZXR3b3JrMSMwIQYJ
KoZIhvcNAQkBFhRlcmljbGF5bGF5QGdtYWlsLmNvbTAeFw0yMjA5MjAwMzUzMDda
Fw0zMjA5MTcwMzUzMDdaMIGqMQswCQYDVQQGEwJQSDELMAkGA1UECBMCTUExFjAU
BgNVBAcTDUFudGlwb2xvIENpdHkxEjAQBgNVBAoTCVRLTmV0d29yazESMBAGA1UE
CxMJVEtOZXJ3b3JrMRUwEwYDVQQDEwxUS05ldHdvcmsgQ0ExEjAQBgNVBCkTCVRL
TmV0d29yazEjMCEGCSqGSIb3DQEJARYUZXJpY2xheWxheUBnbWFpbC5jb20wggEi
MA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCdQ4Q5U25/QyOPi9s7X9GrzKYh
huF5twr7rneZrJPWKy7rDDvhpUOqTyv/FI3PX3BbZKbXOnFGxFyNpkqnL/5nyoxa
ma5WeYgcCN4PHmUd46bOX7HFl7ydHo+OutDM9xP8g8VOfFDjiNjlcpI0qTkBOm2k
um5Bx7Z6CxDblT+iXAQ1Pv0F7EYclKcAxSlEwG/phdXTkshx7wsqzilorouLoZ4N
iB+Sv7vWQY1i0HS3IOv9xG0xTW5LKt3ub5ZrkIs+JBXlyR3L953i3OzP3uQ9gQcL
/w/6XSN1opR3NYfFpL4QsSVJDRiASU9oWyuyZ2K/hiFdMG9vpwjMomEINDRxAgMB
AAGjggEeMIIBGjAdBgNVHQ4EFgQU22vZfsw2ER5n6EWwByaIF/aL86swgeoGA1Ud
IwSB4jCB34AU22vZfsw2ER5n6EWwByaIF/aL86uhgbCkga0wgaoxCzAJBgNVBAYT
AlBIMQswCQYDVQQIEwJNQTEWMBQGA1UEBxMNQW50aXBvbG8gQ2l0eTESMBAGA1UE
ChMJVEtOZXR3b3JrMRIwEAYDVQQLEwlUS05lcndvcmsxFTATBgNVBAMTDFRLTmV0
d29yayBDQTESMBAGA1UEKRMJVEtOZXR3b3JrMSMwIQYJKoZIhvcNAQkBFhRlcmlj
bGF5bGF5QGdtYWlsLmNvbYIUUmdgPaIpFzVfyrlKjuKAdPPOZOswDAYDVR0TBAUw
AwEB/zANBgkqhkiG9w0BAQsFAAOCAQEAFxk8YMHYAjggbj6T8HliynV/fMEbhZxx
HIpQyUmOhUOf1LidztC6w/cpO7Cx+esobwfgxGFnx854cnDHZ77/MmZHiGV3Rn91
rmv3xPc0FFiH+Cb4IVXtaPr1hUE45Eey+Odpy3Tj9wOC29lS4P5q9GgcnuNXj4Db
W/jcb2uW3xcdHPj1slhy4Wl/h6Qe5vHqp2jOfMZISKiF3keTAiYnXJWTsSPeOkOD
NvgKUnh6Z3K8NaUlw0SyhzMVwKDKExmMQUcHXAtF2JDrQwerB29jQBd+iFNVV3in
Pz2wHWMTqDV4pSJL4APX/Y9TC7jsi7d0rq9+gmOOFp1OAe11PSTamg==
-----END CERTIFICATE-----
EOF

cat << EOF > /etc/openvpn/easy-rsa/keys/server.crt
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number: 1 (0x1)
        Signature Algorithm: sha256WithRSAEncryption
        Issuer: C=PH, ST=MA, L=Caloocan City, O=YModified, OU=YModified, CN=YModified CA/name=YModified/emailAddress=ymodified23@gmail.com
        Validity
            Not Before: Sep 20 03:54:08 2022 GMT
            Not After : Sep 17 03:54:08 2032 GMT
        Subject: C=PH, ST=CA, L=Caloocan City, O=YModified, OU=YModified, CN=YModified/name=YModified/emailAddress=ymodified23@gmail.com
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
                DirName:/C=PH/ST=MA/L=Caloocan City/O=YModified/OU=YModified/CN=YModified CA/name=YModified/emailAddress=ymodified23@gmail.com
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

cat << EOF > /etc/openvpn/easy-rsa/keys/server.key
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

cat << EOF > /etc/openvpn/easy-rsa/keys/dh.pem
-----BEGIN DH PARAMETERS-----
MIIBCAKCAQEAuAz9Bv9pwxWbbb8BQZ/TxfRtI6pStmlhgDbuZbAWj5KL2dHabaHd
xmbijMA3XM0VYzwrtVldeu9ejrJ16fWKDdjkBFxhHXNWyJjz5IqATpujsr9ft0zK
9UZlkSFiJJQj5rZXd7Ls6SyPE6u/lfude12D3GF0uEUg0YPwl9n6J6Hmjo4UZ1HJ
DXfuYxY9CVKEXBfNqxshQw4FuNqZajCCA9dWdYZDOkzcWo2QQYxXBWLwJZZ4EKY9
aNu/vLxRe+2b3gUSkE6KIhN5/2fQyZgVY4NGkTtDIbLlpwQO/ZT/kFwJ8RShWdOo
XarEe9JDuh1eOZcl4ZEbXjC6r3GnuOb/+wIBAg==
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
#echo "Installing iptables."

echo "net.ipv4.ip_forward=1
net.ipv4.conf.all.rp_filter=0
net.ipv4.conf.eth0.rp_filter=0
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf

sysctl -p

iptables -F
iptables -t nat -A PREROUTING -p udp --dport 20000:50000 -j DNAT --to-destination :5666
iptables -t nat -A POSTROUTING -s 10.20.0.0/22 -o "$server_interface" -j MASQUERADE
iptables -t nat -A POSTROUTING -s 10.20.0.0/22 -o "$server_interface" -j SNAT --to-source "$server_ip"
iptables -t nat -A POSTROUTING -s 10.30.0.0/22 -o "$server_interface" -j MASQUERADE
iptables -t nat -A POSTROUTING -s 10.30.0.0/22 -o "$server_interface" -j SNAT --to-source "$server_ip"
iptables -t filter -A INPUT -p udp -m udp --dport 20100:20900 -m state --state NEW -m recent --update --seconds 30 --hitcount 10 --name DEFAULT --mask 255.255.255.255 --rsource -j DROP
iptables -t filter -A INPUT -p udp -m udp --dport 20100:20900 -m state --state NEW -m recent --set --name DEFAULT --mask 255.255.255.255 --rsource
iptables-save > /etc/iptables_rules.v4
ip6tables-save > /etc/iptables_rules.v6
#}&>/dev/null
}

install_stunnel() {
  {
cd /etc/stunnel/ || exit

echo "-----BEGIN PRIVATE KEY-----
MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQClmgCdm7RB2VWK
wfH8HO/T9bxEddWDsB3fJKpM/tiVMt4s/WMdGJtFdRlxzUb03u+HT6t00sLlZ78g
ngjxLpJGFpHAGdVf9vACBtrxv5qcrG5gd8k7MJ+FtMTcjeQm8kVRyIW7cOWxlpGY
6jringYZ6NcRTrh/OlxIHKdsLI9ddcekbYGyZVTm1wd22HVG+07PH/AeyY78O2+Z
tbjxGTFRSYt3jUaFeUmWNtxqWnR4MPmC+6iKvUKisV27P89g8v8CiZynAAWRJ0+A
qp+PWxwHi/iJ501WdLspeo8VkXIb3PivyIKC356m+yuuibD2uqwLZ2//afup84Qu
pRtgW/PbAgMBAAECggEAVo/efIQUQEtrlIF2jRNPJZuQ0rRJbHGV27tdrauU6MBT
NG8q7N2c5DymlT75NSyHRlKVzBYTPDjzxgf1oqR2X16Sxzh5uZTpthWBQtal6fmU
JKbYsDDlYc2xDZy5wsXnCC3qAaWs2xxadPUS3Lw/cjGsoeZlOFP4QtV/imLseaws
7r4KZE7SVO8dF8Xtcy304Bd7UsKClnbCrGsABUF/rqA8g34o7yrpo9XqcwbF5ihQ
TbnB0Ns8Bz30pjgGjJZTdTL3eskP9qMJWo/JM76kSaJWReoXTws4DlQHxO29z3eK
zKdxieXaBGMwFnv23JvXKJ5eAnxzqsL6a+SuNPPN4QKBgQDQhisSDdjUJWy0DLnJ
/HjtsnQyfl0efOqAlUEir8r5IdzDTtAEcW6GwPj1rIOm79ZeyysT1pGN6eulzS1i
6lz6/c5uHA9Z+7LT48ZaQjmKF06ItdfHI9ytoXaaQPMqW7NnyOFxCcTHBabmwQ+E
QZDFkM6vVXL37Sz4JyxuIwCNMQKBgQDLThgKi+L3ps7y1dWayj+Z0tutK2JGDww7
6Ze6lD5gmRAURd0crIF8IEQMpvKlxQwkhqR4vEsdkiFFJQAaD+qZ9XQOkWSGXvKP
A/yzk0Xu3qL29ZqX+3CYVjkDbtVOLQC9TBG60IFZW79K/Zp6PhHkO8w6l+CBR+yR
X4+8x1ReywKBgQCfSg52wSski94pABugh4OdGBgZRlw94PCF/v390En92/c3Hupa
qofi2mCT0w/Sox2f1hV3Fw6jWNDRHBYSnLMgbGeXx0mW1GX75OBtrG8l5L3yQu6t
SeDWpiPim8DlV52Jp3NHlU3DNrcTSOFgh3Fe6kpot56Wc5BJlCsliwlt0QKBgEol
u0LtbePgpI2QS41ewf96FcB8mCTxDAc11K6prm5QpLqgGFqC197LbcYnhUvMJ/eS
W53lHog0aYnsSrM2pttr194QTNds/Y4HaDyeM91AubLUNIPFonUMzVJhM86FP0XK
3pSBwwsyGPxirdpzlNbmsD+WcLz13GPQtH2nPTAtAoGAVloDEEjfj5gnZzEWTK5k
4oYWGlwySfcfbt8EnkY+B77UVeZxWnxpVC9PhsPNI1MTNET+CRqxNZzxWo3jVuz1
HtKSizJpaYQ6iarP4EvUdFxHBzjHX6WLahTgUq90YNaxQbXz51ARpid8sFbz1f37
jgjgxgxbitApzno0E2Pq/Kg=
-----END PRIVATE KEY-----
-----BEGIN CERTIFICATE-----
MIIDRTCCAi2gAwIBAgIUOvs3vdjcBtCLww52CggSlAKafDkwDQYJKoZIhvcNAQEL
BQAwMjEQMA4GA1UEAwwHS29ielZQTjERMA8GA1UECgwIS29iZUtvYnoxCzAJBgNV
BAYTAlBIMB4XDTIxMDcwNzA1MzQwN1oXDTMxMDcwNTA1MzQwN1owMjEQMA4GA1UE
AwwHS29ielZQTjERMA8GA1UECgwIS29iZUtvYnoxCzAJBgNVBAYTAlBIMIIBIjAN
BgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEApZoAnZu0QdlVisHx/Bzv0/W8RHXV
g7Ad3ySqTP7YlTLeLP1jHRibRXUZcc1G9N7vh0+rdNLC5We/IJ4I8S6SRhaRwBnV
X/bwAgba8b+anKxuYHfJOzCfhbTE3I3kJvJFUciFu3DlsZaRmOo64p4GGejXEU64
fzpcSBynbCyPXXXHpG2BsmVU5tcHdth1RvtOzx/wHsmO/DtvmbW48RkxUUmLd41G
hXlJljbcalp0eDD5gvuoir1CorFduz/PYPL/AomcpwAFkSdPgKqfj1scB4v4iedN
VnS7KXqPFZFyG9z4r8iCgt+epvsrromw9rqsC2dv/2n7qfOELqUbYFvz2wIDAQAB
o1MwUTAdBgNVHQ4EFgQUcKFL6tckon2uS3xGrpe1Zpa68VEwHwYDVR0jBBgwFoAU
cKFL6tckon2uS3xGrpe1Zpa68VEwDwYDVR0TAQH/BAUwAwEB/zANBgkqhkiG9w0B
AQsFAAOCAQEAYQP0S67eoJWpAMavayS7NjK+6KMJtlmL8eot/3RKPLleOjEuCdLY
QvrP0Tl3M5gGt+I6WO7r+HKT2PuCN8BshIob8OGAEkuQ/YKEg9QyvmSm2XbPVBaG
RRFjvxFyeL4gtDlqb9hea62tep7+gCkeiccyp8+lmnS32rRtFa7PovmK5pUjkDOr
dpvCQlKoCRjZ/+OfUaanzYQSDrxdTSN8RtJhCZtd45QbxEXzHTEaICXLuXL6cmv7
tMuhgUoefS17gv1jqj/C9+6ogMVa+U7QqOvL5A7hbevHdF/k/TMn+qx4UdhrbL5Q
enL3UGT+BhRAPiA1I5CcG29RqjCzQoaCNg==
-----END CERTIFICATE-----" >> stunnel.pem

echo "debug = 0
output = /tmp/stunnel.log
cert = /etc/stunnel/stunnel.pem
[ssh]
connect = 22  
accept = 445 
[openvpn-tcp]
connect = PORT_TCP  
accept = 443 
[openvpn-udp]
connect = PORT_UDP
accept = 444
" >> stunnel.conf

sed -i "s|PORT_TCP|$PORT_TCP|g" /etc/stunnel/stunnel.conf
sed -i "s|PORT_UDP|$PORT_UDP|g" /etc/stunnel/stunnel.conf
cd /etc/default && rm stunnel4

echo 'ENABLED=1
FILES="/etc/stunnel/*.conf"
OPTIONS=""
PPP_RESTART=0
RLIMITS=""' >> stunnel4 

chmod 755 stunnel4
sudo service stunnel4 restart
  } &>/dev/null
}

install_hysteria(){
clear
echo 'Installing hysteria.'
{
wget -N --no-check-certificate -q -O ~/install_server.sh https://raw.githubusercontent.com/RepositoriesDexter/Hysteria/main/install_server.sh; chmod +x ~/install_server.sh; ./install_server.sh --version v1.3.5

rm -f /etc/hysteria/config.json

echo '{
  "listen": ":5666",
  "cert": "/etc/hysteria/hysteria.crt",
  "key": "/etc/hysteria/hysteria.key",
  "up_mbps": 100,
  "down_mbps": 100,
  "disable_udp": false,
  "obfs": "ymodified",
  "auth": {
    "mode": "passwords",
    "config": ["ymodified"]
  }
}
' >> /etc/hysteria/config.json

chmod 755 /etc/hysteria/config.json

sysctl -w net.core.rmem_max=16777216
sysctl -w net.core.wmem_max=16777216

wget -O /usr/bin/badvpn-udpgw "https://raw.githubusercontent.com/freenetsapinas/ymod/main/badvpn-udpgw64"
chmod +x /usr/bin/badvpn-udpgw
ps x | grep 'udpvpn' | grep -v 'grep' || screen -dmS udpvpn /usr/bin/badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 10000 --max-connections-for-client 10 --client-socket-sndbuf 10000
} &>/dev/null
}

setup_ssl() {
#Creating Hysteria CERT
cat << EOF > /etc/hysteria/hysteria.crt
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            40:26:da:91:18:2b:77:9c:85:6a:0c:bb:ca:90:53:fe
        Signature Algorithm: sha256WithRSAEncryption
        Issuer: CN=KobZ
        Validity
            Not Before: Jul 22 22:23:55 2020 GMT
            Not After : Jul 20 22:23:55 2030 GMT
        Subject: CN=server
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                RSA Public-Key: (1024 bit)
                Modulus:
                    00:ce:35:23:d8:5d:9f:b6:9b:cb:6a:89:e1:90:af:
                    42:df:5f:f8:bd:ad:a7:78:9a:ca:20:f0:3d:5b:d6:
                    c9:ef:4c:4a:99:96:c3:38:fd:59:b4:d7:65:ed:d4:
                    a7:fa:ab:03:e2:be:88:2f:ca:fc:90:dd:b0:b7:bc:
                    23:cb:83:ac:36:e2:01:57:69:64:b8:e1:9e:51:f0:
                    a6:9d:13:d9:92:6b:4d:04:a6:10:64:a3:3f:6b:ff:
                    fe:32:ac:91:63:c2:71:24:be:9e:76:4f:87:cc:3a:
                    03:a1:9e:48:3f:11:92:33:3b:19:16:9c:d0:5d:16:
                    ee:c1:42:67:99:47:66:67:67
                Exponent: 65537 (0x10001)
        X509v3 extensions:
            X509v3 Basic Constraints: 
                CA:FALSE
            X509v3 Subject Key Identifier: 
                6B:08:C0:64:10:71:A8:32:7F:0B:FE:1E:98:1F:BD:72:74:0F:C8:66
            X509v3 Authority Key Identifier: 
                keyid:64:49:32:6F:FE:66:62:F1:57:4D:BB:91:A8:5D:BD:26:3E:51:A4:D2
                DirName:/CN=KobZ
                serial:01:A4:01:02:93:12:D9:D6:01:A9:83:DC:03:73:DA:ED:C8:E3:C3:B7
            X509v3 Extended Key Usage: 
                TLS Web Server Authentication
            X509v3 Key Usage: 
                Digital Signature, Key Encipherment
            X509v3 Subject Alternative Name: 
                DNS:server
    Signature Algorithm: sha256WithRSAEncryption
         a1:3e:ac:83:0b:e5:5d:ca:36:b7:d0:ab:d0:d9:73:66:d1:62:
         88:ce:3d:47:9e:08:0b:a0:5b:51:13:fc:7e:d7:6e:17:0e:bd:
         f5:d9:a9:d9:06:78:52:88:5a:e5:df:d3:32:22:4a:4b:08:6f:
         b1:22:80:4f:19:d1:5f:9d:b6:5a:17:f7:ad:70:a9:04:00:ff:
         fe:84:aa:e1:cb:0e:74:c0:1a:75:0b:3e:98:90:1d:22:ba:a4:
         7a:26:65:7d:d1:3b:5c:45:a1:77:22:ed:b6:6b:18:a3:c4:ee:
         3e:06:bb:0b:ec:12:ac:16:a5:50:b3:ed:46:43:87:72:fd:75:
         8c:38
-----BEGIN CERTIFICATE-----
MIICVDCCAb2gAwIBAgIQQCbakRgrd5yFagy7ypBT/jANBgkqhkiG9w0BAQsFADAP
MQ0wCwYDVQQDDARLb2JaMB4XDTIwMDcyMjIyMjM1NVoXDTMwMDcyMDIyMjM1NVow
ETEPMA0GA1UEAwwGc2VydmVyMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDO
NSPYXZ+2m8tqieGQr0LfX/i9rad4msog8D1b1snvTEqZlsM4/Vm012Xt1Kf6qwPi
vogvyvyQ3bC3vCPLg6w24gFXaWS44Z5R8KadE9mSa00EphBkoz9r//4yrJFjwnEk
vp52T4fMOgOhnkg/EZIzOxkWnNBdFu7BQmeZR2ZnZwIDAQABo4GuMIGrMAkGA1Ud
EwQCMAAwHQYDVR0OBBYEFGsIwGQQcagyfwv+HpgfvXJ0D8hmMEoGA1UdIwRDMEGA
FGRJMm/+ZmLxV027kahdvSY+UaTSoROkETAPMQ0wCwYDVQQDDARLb2JaghQBpAEC
kxLZ1gGpg9wDc9rtyOPDtzATBgNVHSUEDDAKBggrBgEFBQcDATALBgNVHQ8EBAMC
BaAwEQYDVR0RBAowCIIGc2VydmVyMA0GCSqGSIb3DQEBCwUAA4GBAKE+rIML5V3K
NrfQq9DZc2bRYojOPUeeCAugW1ET/H7XbhcOvfXZqdkGeFKIWuXf0zIiSksIb7Ei
gE8Z0V+dtloX961wqQQA//6EquHLDnTAGnULPpiQHSK6pHomZX3RO1xFoXci7bZr
GKPE7j4GuwvsEqwWpVCz7UZDh3L9dYw4
-----END CERTIFICATE-----
EOF

cat << EOF > /etc/hysteria/hysteria.key
-----BEGIN PRIVATE KEY-----
MIICdQIBADANBgkqhkiG9w0BAQEFAASCAl8wggJbAgEAAoGBAM41I9hdn7aby2qJ
4ZCvQt9f+L2tp3iayiDwPVvWye9MSpmWwzj9WbTXZe3Up/qrA+K+iC/K/JDdsLe8
I8uDrDbiAVdpZLjhnlHwpp0T2ZJrTQSmEGSjP2v//jKskWPCcSS+nnZPh8w6A6Ge
SD8RkjM7GRac0F0W7sFCZ5lHZmdnAgMBAAECgYAFNrC+UresDUpaWjwaxWOidDG8
0fwu/3Lm3Ewg21BlvX8RXQ94jGdNPDj2h27r1pEVlY2p767tFr3WF2qsRZsACJpI
qO1BaSbmhek6H++Fw3M4Y/YY+JD+t1eEBjJMa+DR5i8Vx3AE8XOdTXmkl/xK4jaB
EmLYA7POyK+xaDCeEQJBAPJadiYd3k9OeOaOMIX+StCs9OIMniRz+090AJZK4CMd
jiOJv0mbRy945D/TkcqoFhhScrke9qhgZbgFj11VbDkCQQDZ0aKBPiZdvDMjx8WE
y7jaltEDINTCxzmjEBZSeqNr14/2PG0X4GkBL6AAOLjEYgXiIvwfpoYE6IIWl3re
ebCfAkAHxPimrixzVGux0HsjwIw7dl//YzIqrwEugeSG7O2Ukpz87KySOoUks3Z1
yV2SJqNWskX1Q1Xa/gQkyyDWeCeZAkAbyDBI+ctc8082hhl8WZunTcs08fARM+X3
FWszc+76J1F2X7iubfIWs6Ndw95VNgd4E2xDATNg1uMYzJNgYvcTAkBoE8o3rKkp
em2n0WtGh6uXI9IC29tTQGr3jtxLckN/l9KsJ4gabbeKNoes74zdena1tRdfGqUG
JQbf7qSE3mg2
-----END PRIVATE KEY-----
EOF

chmod 755 /etc/hysteria/config.json
chmod 755 /etc/hysteria/hysteria.crt
chmod 755 /etc/hysteria/hysteria.key
}

server_authentication(){
mkdir -p /etc/authorization/pandavpnunite
wget -O /etc/authorization/pandavpnunite/connection.php "https://raw.githubusercontent.com/reyluar18/pandavpnunite/main/cron.sh"
echo "* * * * * /usr/bin/php /etc/authorization/pandavpnunite/connection.php
* * * * * /bin/bash /etc/authorization/pandavpnunite/active.sh
* * * * * /bin/bash /etc/authorization/pandavpnunite/not-active.sh" | tee -a /var/spool/cron/root

}   


install_rclocal(){
  {
  sed -i 's/Listen 80/Listen 81/g' /etc/apache2/ports.conf
    systemctl restart apache2
    
    sudo systemctl restart stunnel4
    sudo systemctl enable openvpn@server.service
    sudo systemctl start openvpn@server.service
    sudo systemctl enable openvpn@server2.service
    sudo systemctl start openvpn@server2.service    
    
    echo "[Unit]
Description=michaele service
Documentation=http://ymodified.online

[Service]
Type=oneshot
ExecStart=/bin/bash /etc/rc.local
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target" >> /etc/systemd/system/michaele.service
    echo '#!/bin/sh -e
service ufw stop
iptables-restore < /etc/iptables_rules.v4
ip6tables-restore < /etc/iptables_rules.v6
sysctl -p
service stunnel4 restart
systemctl restart openvpn@server.service
systemctl restart openvpn@server2.service
screen -dmS socks python /etc/socks.py 80
ps x | grep 'udpvpn' | grep -v 'grep' || screen -dmS udpvpn /usr/bin/badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 10000 --max-connections-for-client 10 --client-socket-sndbuf 10000
screen -dmS webinfo php -S 0.0.0.0:5623 -t /root/.web/
bash /etc/hysteria/monitor.sh openvpn
bash /etc/hysteria/online.sh
exit 0' >> /etc/rc.local
    sudo chmod +x /etc/rc.local
    systemctl daemon-reload
    sudo systemctl enable michaele
    sudo systemctl start michaele.service
    
    mkdir -m 777 /root/.web
echo "Made with love by: Michaele Abalos... " >> /root/.web/index.php

echo "tcp_port=TCP_PORT
udp_port=UDP_PORT
socket_port=80
squid_port=8080
hysteria_port=5666
tcp_ssl_port=1194
udp_ssl_port=442" >> /root/.ports

sed -i "s|TCP_PORT|$PORT_TCP|g" /root/.ports
sed -i "s|UDP_PORT|$PORT_UDP|g" /root/.ports

sed -i "s|SERVERIP|$server_ip|g" /etc/.counter
  }&>/dev/null
}

start_service () {
clear
echo 'Starting..'
{

sudo crontab -l | { echo "* * * * * pgrep -x stunnel4 >/dev/null && echo 'GOOD' || /etc/init.d/stunnel4 restart"; } | crontab -
sudo systemctl restart cron
} &>/dev/null
clear
systemctl enable hysteria-server.service
systemctl restart hysteria-server.service
history -c;
rm /etc/.systemlink
echo -e " \033[0;35m══════════════════════════════════════════════════════════════════\033[0m"
echo '#############################################
#         Authentication file system        #
#       Setup by: Pandavpn Unite            #
#       Server System: Panda VPN 	        #
#            owner: Pandavpnunite      	    #
#############################################                      
 '
echo -e " \033[0;35m══════════════════════════════════════════════════════════════════\033[0m"
netstat -tpln
echo -e " \033[0;35m══════════════════════════════════════════════════════════════════\033[0m"
echo -e " \033[0;31m Server will secure this server and reboot after 10 seconds!! \033[0m"
echo -e " \033[0;35m══════════════════════════════════════════════════════════════════\033[0m"
sleep 10
reboot
}

install_require
install_hysteria
setup_ssl
install_squid
install_openvpn
install_firewall_kvm
install_stunnel
install_rclocal
server_authentication
start_service
