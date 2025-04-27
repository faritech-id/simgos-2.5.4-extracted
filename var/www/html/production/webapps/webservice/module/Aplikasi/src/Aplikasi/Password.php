<?php
namespace Aplikasi;

use DBService\DatabaseService;
use DBService\System;

class Password
{
	CONST TYPE_ENCRYPT_MD5_WITH_KEY = 1;
	CONST TYPE_ENCRYPT_MD5_ONLY = 2;
	CONST TYPE_ENCRYPT_MYSQL_PASS = 3; // depricated
	CONST TYPE_ENCRYPT_SHA256_PASS_HASH = 4;
	
	private static $private_key = "KDFLDMSTHBWWSGCBH";
    public static function encrypt($key, $type = Password::TYPE_ENCRYPT_SHA256_PASS_HASH) {
		if($type == Password::TYPE_ENCRYPT_MD5_ONLY) {
			return md5($key);
		}
		/* Depricated
		if($type == Password::TYPE_ENCRYPT_MYSQL_PASS) {			
			$db = DatabaseService::get("SIMpel");			
			$adapter = $db->getAdapter();			
			return System::getPassword($adapter, $key);
		}
		*/
		if($type == Password::TYPE_ENCRYPT_MD5_WITH_KEY) {
			return md5(self::$private_key.md5($key).self::$private_key);
		}

		$hash = hash_hmac("sha256", $key, hash("sha256", self::$private_key, false), false);

		return password_hash($hash, PASSWORD_BCRYPT);
	}

	public static function verify($passDb, $passInput) {
		if($passDb == Password::encrypt($passInput, Password::TYPE_ENCRYPT_MD5_WITH_KEY)) return true;
		if($passDb == Password::encrypt($passInput, Password::TYPE_ENCRYPT_MD5_ONLY)) return true;

		// Depricated
		//if($passDb == Password::encrypt($passInput, Password::TYPE_ENCRYPT_MYSQL_PASS)) return true;

		$hash = hash_hmac("sha256", $passInput, hash("sha256", self::$private_key, false), false);
		if(password_verify($hash, $passDb)) {
			return true;
		}
		return false;
	}
}
