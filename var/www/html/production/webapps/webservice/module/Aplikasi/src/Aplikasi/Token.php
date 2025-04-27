<?php

namespace Aplikasi;

use DBService\DatabaseService;
use \DateTime;
use \DateTimeZone;
use \Exception;

class Token
{
	private $xheader;
	private $xId;
	private $xTimestamp;
	private $xToken;
	private $xPass;
	private $xVerifToken;


	public function __construct($xheader)
	{
		if ($xheader) {
			$x_token = base64_decode($xheader->getFieldValue());
			$dataArr = explode("&", $x_token);
			$this->xVerifToken = $xheader->getFieldValue();
			$this->xId = $dataArr[0];
			$this->xTimestamp = $dataArr[1];
			$this->xToken = $dataArr[2];
			$this->xPass = $dataArr[3];
		}
	}

	public function getXId()
	{
		return $this->xId;
	}

	public function getXRef()
	{
		return $this->xRef;
	}

	public function isValidToken()
	{
		if (!$this->xId || !$this->xTimestamp || !$this->xToken) {
			throw new Exception("Token Required", 428);
		}
		$ts = $this->getTimestamp();
		if (($ts - $this->xTimestamp) > 3600) throw new Exception("Token is Expired", 408);
		$data = $this->cekUsers($this->xId, $this->xPass);
		if ($data) {
			if ($data["STATUS"] == 0) throw new Exception("Token is not found / registered", 401);
			$signToken = $this->generateToken($data, $this->xTimestamp);
			if ($signToken == $this->xVerifToken) return true;
			throw new Exception("Invalid Token", 401);
		} else {
			throw new Exception("Token is not found / registered", 401);
		}

		return true;
	}

	private function cekUsers($xid, $xpass)
	{
		$db = DatabaseService::get("SIMpel");
		$adapter = $db->getAdapter();

		$stmt = $adapter->query("
			SELECT *
			  FROM aplikasi.signature
			 WHERE X_ID = ? 
			   AND MD5(X_PASS) = ?");
		$results = $stmt->execute([$xid, $xpass]);
		return $results->current();
	}

	public function getTimestamp()
	{
		$dt = new DateTime(null, new DateTimeZone("UTC"));
		return $dt->getTimestamp();
	}

	public function generateToken($data, $xtimestamp)
	{
		$key = $data["X_ID"] . "&" . $xtimestamp;
		return base64_encode($key . "&" . md5($key) . "&" . md5($data["X_PASS"]));
	}

	public function createToken($id, $pass)
	{
		$ts = $this->getTimestamp();
		$key = $id . "&" . $ts;
		return base64_encode($key . "&" . md5($key) . "&" . md5($pass));
	}
}