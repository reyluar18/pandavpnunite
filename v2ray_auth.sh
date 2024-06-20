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

function encrypt_key($paswd)
	{
	  $mykey=getEncryptKey();
	  $encryptedPassword=encryptPaswd($paswd,$mykey);
	  return $encryptedPassword;
	}
	 
	function decrypt_key($paswd)
	{
	  $mykey=getEncryptKey();
	  $decryptedPassword=decryptPaswd($paswd,$mykey);
	  return $decryptedPassword;
	}
	 
	function getEncryptKey()
	{
		$secret_key = md5('eugcar');
		$secret_iv = md5('sanchez');
		$keys = $secret_key . $secret_iv;
		return encryptor('encrypt', $keys);
	}
	function encryptPaswd($string, $key)
	{
	  $result = '';
	  for($i=0; $i<strlen ($string); $i++)
	  {
		$char = substr($string, $i, 1);
		$keychar = substr($key, ($i % strlen($key))-1, 1);
		$char = chr(ord($char)+ord($keychar));
		$result.=$char;
	  }
		return base64_encode($result);
	}
	 
	function decryptPaswd($string, $key)
	{
	  $result = '';
	  $string = base64_decode($string);
	  for($i=0; $i<strlen($string); $i++)
	  {
		$char = substr($string, $i, 1);
		$keychar = substr($key, ($i % strlen($key))-1, 1);
		$char = chr(ord($char)-ord($keychar));
		$result.=$char;
	  }
	 
		return $result;
	}
	
	function encryptor($action, $string) {
		$output = false;

		$encrypt_method = "AES-256-CBC";
		
		$secret_key = md5('eugcar sanchez');
		$secret_iv = md5('sanchez eugcar');

		
		$key = hash('sha256', $secret_key);
		
		
		$iv = substr(hash('sha256', $secret_iv), 0, 16);

		
		if( $action == 'encrypt' ) {
			$output = openssl_encrypt($string, $encrypt_method, $key, 0, $iv);
			$output = base64_encode($output);
		}
		else if( $action == 'decrypt' ){
			
			$output = openssl_decrypt(base64_decode($string), $encrypt_method, $key, 0, $iv);
		}

		return $output;
	}



$data = '';
$uuid = array();
$premium_active = "status='live' AND is_freeze=0 AND is_ban=0 AND duration > 0";
$vip_active = "status='live' AND is_freeze=0 AND is_ban=0 AND vip_duration > 0";
$private_active = "status='live' AND is_freeze=0 AND is_ban=0 AND private_duration > 0";
$query = $mysqli->query("SELECT * FROM users WHERE ".$premium_active." OR ".$vip_active." OR ".$private_active." ORDER by user_id DESC");
if($query->num_rows > 0)
{
	while($row = $query->fetch_assoc())
	{
		$v2ray_id = $row['v2ray_id'];
		if($v2ray_id != '')
		{
  		$array = [
  				"user" => $v2ray_id,
  			];
  		array_push($uuid, $array);
		}
		
	}
}

$mysqli->close();
# echo json_encode($uuid);
$location = '/etc/authorization/pandavpnunite/v2ray.txt';
$fp = fopen($location, 'w');
fwrite($fp, json_encode($uuid)) or die("Unable to open file!");
fclose($fp);
?>

