<?php
namespace DBService;

use LZCompressor\LZString;

class Crypto {
	private $ivLength = 32;
	private $iterations = 10000;
	private $digest_algorithm = "sha256";
	private $cipher = "aes-256-cbc";
	private $key;
	
	public function __construct($options = array()) {		
		if(is_array($options)) {
			if(isset($options["cipher"])) $this->cipher = $options["cipher"];
			if(isset($options["key"])) $this->key = $options["key"];
		}
		
		$this->ivLength = openssl_cipher_iv_length($this->cipher);
	}
	
	public function generateKey($pass, $length = 32, $pbkdf2 = true) {
		$iv = openssl_random_pseudo_bytes($length);
		$key = $iv;
		if($pbkdf2) $key = openssl_pbkdf2($pass, $iv, $length, $this->iterations, $this->digest_algorithm);
		$this->key = bin2hex($key);
		return $this->key;
	}
	
	public function setKey($key) {
		$this->key = $key;
	}
	
	public function encrypt($data, $utf8 = false, $compress = false) {
		$key = hex2bin($this->key);
		$iv = openssl_random_pseudo_bytes($this->ivLength);
		$data = $compress ? LZString::compressToEncodedURIComponent($data) : $data;	
		$encrypted = openssl_encrypt($data, $this->cipher, $key, OPENSSL_RAW_DATA, $iv);		
		if($utf8) return chunk_split(base64_encode(utf8_encode($iv.$encrypted)));
		else return chunk_split(base64_encode($iv.$encrypted));
	}
	
	public function decrypt($data, $utf8 = false, $compress = false) {
		$key = hex2bin($this->key);
		$decoded = base64_decode($data);
		if($utf8) $decoded = utf8_decode($decoded);
		$iv = mb_substr($decoded, 0, $this->ivLength, "8bit");
		$encrypted = mb_substr($decoded, $this->ivLength, null, "8bit");
		$decrypted = openssl_decrypt($encrypted, $this->cipher, $key, OPENSSL_RAW_DATA, $iv);
		$decrypted = $compress ? LZString::decompressFromEncodedURIComponent($decrypted) : $decrypted;
		return $decrypted;
	}
}