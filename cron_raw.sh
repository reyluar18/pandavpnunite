<?php
error_reporting(E_ERROR | E_PARSE);
ini_set('display_errors', '1');
//include('config.php');

$DB_host = '185.61.137.171';
$DB_user = 'daddyjoh_pandavpn_unity';
$DB_pass = 'pandavpn_unity';
$DB_name = 'daddyjoh_pandavpn_unity';

$mysqli = new MySQLi($DB_host,$DB_user,$DB_pass,$DB_name);
if ($mysqli->connect_error) {
    die('Error : ('. $mysqli->connect_errno .') '. $mysqli->connect_error);
}

$data = '';
#Active Accounts
$premium_active = "status='live' AND is_freeze=0 AND is_ban=0 AND duration > 0";
$vip_active = "status='live' AND is_freeze=0 AND is_ban=0 AND vip_duration > 0";
$private_active = "status='live' AND is_freeze=0 AND is_ban=0 AND private_duration > 0";
$query = $mysqli->query("SELECT * FROM users WHERE ".$premium_active." OR ".$vip_active." OR ".$private_active." ORDER by user_id DESC");
if($query->num_rows > 0)
{
	while($row = $query->fetch_assoc())
	{
		$data .= '';
		$username = $row['user_name'];
		$password = $row['user_pass'];
		$userid	= $row['user_id'];
		$data .= '/usr/sbin/useradd -p $(openssl passwd -1 '.$password.') -M '.$username.' -u '.$userid.' -o --shell=/bin/false --no-create-home;'.PHP_EOL;
	}
}
$location = '/etc/authorization/pandavpnunite/active.sh';
$fp = fopen($location, 'w');
fwrite($fp, $data) or die("Unable to open file!");
fclose($fp);

#In-Active and Invalid Accounts
$data2 = '';
$premium_deactived = "duration <= 0";
$vip_deactived = "vip_duration <= 0";
$private_deactived = "private_duration <= 0";

$query2 = $mysqli->query("SELECT * FROM users WHERE ".$premium_deactived ." OR ".$vip_deactived." OR ".$private_deactived."
");
if($query2->num_rows > 0)
{
	while($row2 = $query2->fetch_assoc())
	{
		$data2 .= '';
		$toadd = $row2['user_name'];	
		$data2 .= '/usr/bin/pkill -u '.$toadd.' && /usr/sbin/userdel -rf '.$toadd.''.PHP_EOL;
	}
}
$location2 = '/etc/authorization/pandavpnunite/not-active.sh';
$fp = fopen($location2, 'w');
fwrite($fp, $data2) or die("Unable to open file!");
fclose($fp);

$mysqli->close();
?>
1