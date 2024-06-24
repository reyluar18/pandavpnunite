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
 

function generateUUIDv4() {
    // Generate 16 bytes (128 bits) of random data or use openssl_random_pseudo_bytes if random_bytes() is not available
    $data = random_bytes(16);

    // Set the version to 0100
    $data[6] = chr(ord($data[6]) & 0x0f | 0x40);

    // Set the variant to 10xxxxxx
    $data[8] = chr(ord($data[8]) & 0x3f | 0x80);

    // Convert to hexadecimal format
    return vsprintf('%s%s-%s-%s-%s-%s%s%s', str_split(bin2hex($data), 4));
}


function isUUIDv1($uuid) {
    // UUIDv1 format regex pattern
    $pattern = '/^[0-9a-f]{8}-[0-9a-f]{4}-1[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i';

    // Check if the provided UUID matches the UUIDv1 pattern
    if (preg_match($pattern, $uuid)) {
        return true;
    } else {
        return false;
    }
}




$data = '';
$uuid = array();
$premium_active = "status='live' AND is_freeze=0 AND is_ban=0 AND duration > 0";
$vip_active = "status='live' AND is_freeze=0 AND is_ban=0 AND vip_duration > 0";
$private_active = "status='live' AND is_freeze=0 AND is_ban=0 AND private_duration > 0";
$query = $mysqli->query("SELECT * FROM users ORDER by user_id DESC");
if($query->num_rows > 0)
{
	while($row = $query->fetch_assoc())
	{
		$user_id = $row['user_id'];
        $v1 = $row['v2ray_id'];
    
    if(isUUIDv1($v1)){
        $uuid = generateUUIDv4();
        $update_query = "UPDATE users SET v2ray_id = '{$uuid}' WHERE user_id = '{$user_id}'";
        if ($mysqli->query($update_query)) {
            echo "Updated v2ray_id for user with ID: {$user_id}: ${$uuid}";
        } else {
            echo "Error updating v2ray_id for user with ID: {$user_id} - " . $mysqli->error . "<br>";
        }
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

