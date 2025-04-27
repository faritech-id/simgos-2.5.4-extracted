<?php
namespace DBService;

use Laminas\Db\Adapter\AdapterInterface;
use Laminas\Stdlib\Hydrator;

abstract class System
{
    public static function getSysDate(AdapterInterface $adapter, $datetime = true, $format = false) {
		$sql = "SELECT NOW() TANGGAL";
        if(!$datetime && !$format) $sql = "SELECT DATE(NOW()) TANGGAL";
		if(!$datetime && $format) $sql = "SELECT DATE_FORMAT(NOW(), '%Y-%m-%d') TANGGAL";
		if($datetime && $format) $sql = "SELECT DATE_FORMAT(NOW(), '%Y-%m-%d %H:%i:%s') TANGGAL";
        $result = $adapter->query($sql, []);
        $data = $result->toArray();
        if(!$data) {
            return false;
        }
        
        return $data[0]['TANGGAL'];
    }

    public static function getDiffTime(AdapterInterface $adapter, $awal, $akhir) {
		$sql = "SELECT TIMEDIFF(?, ?) WAKTU";
        $result = $adapter->query($sql, [$akhir, $awal]);
        $data = $result->toArray();
        if(!$data) {
            return false;
        }
        
        return $data[0]['WAKTU'];
    }
	
	public static function getPassword(AdapterInterface $adapter, $value) {
		//$sql = "SELECT PASSWORD(?) KATA_SANDI";
        $sql = "SELECT UPPER(SHA1(UNHEX(SHA1(?))))) KATA_SANDI";
        $result = $adapter->query($sql, [$value]);
        $data = $result->toArray();
        if(!$data) {
            return false;
        }
        return $data[0]['KATA_SANDI'];
    }
    
    public static function getKey($data=[]) {
        $result = [];
        foreach ($data as $key => $val) {
            $result[count($result)] = $key;
        }
        
        return $result;
    }
    
    public static function getValues($data=[]) {
        $result = [];
        foreach ($data as $key => $val) {
            $result[count($result)] = $val;
        }
        return $result;
    }
	
	public static function objectToArray($object) {
		$hydrator = new Hydrator\ArraySerializable();
		return $hydrator->extract($object);
	}
	
	public static function isNull($params, $nama) {		
		return !isset($params[$nama]) || is_null($params[$nama]);
		//return !isset($params[$nama]) || empty($params[$nama]) || is_null($params[$nama]);
	}

    public static function toUUIDEncode($id) {
		$ids = explode('-', $id);
        if(count($ids) != 5 || strlen($id) != 36) return "";
        $ids[0] = strrev($ids[0]);
        $ids[4] = strrev($ids[4]);
        $ids[2] = strrev($ids[2]);

        $id1 = substr($ids[0], 0, 4);
        $id2 = substr($ids[4], 0, 6);
        $ids[4] = str_replace($id2, $id2.$id1, $ids[4]);
        $ids[0] = str_replace($id1, "", $ids[0]);

        return $ids[0].$ids[4].$ids[3].$ids[1].$ids[2];
	}

    public static function toUUIDDecode($id) {
        if(strlen($id) != 32) return "";
        $id1 = substr($id, 0, 20);
        $id2 = substr($id, 20);
        return strrev(substr($id1, 0, 4)).strrev(substr($id1, 10, 4))
            ."-".substr($id2, 4, 4)
            ."-".strrev(substr($id2, 8))
            ."-".substr($id2, 0, 4)
            ."-".strrev(substr($id1, 14)).strrev(substr($id1, 4, 6));
	}
}
