<?php
namespace LISService\V1\Rest\HasilLog;

use DBService\SystemArrayObject;

class HasilLogEntity extends SystemArrayObject
{
    protected $fields = [
		"ID"=>1
        , "LIS_NO"=>1
		, "HIS_NO_LAB"=>1
		, "LIS_KODE_TEST"=>1
		, "LIS_NAMA_TEST"=>1
		, "LIS_HASIL"=>1
		, "LIS_CATATAN"=>1
		, "LIS_NILAI_NORMAL"=>1
		, "LIS_FLAG" =>1
		, "LIS_SATUAN"=>1
		, "LIS_NAMA_INSTRUMENT"=>1
		, "LIS_TANGGAL"=>1
        , "LIS_USER"=>1
        , "HIS_KODE_TEST"=>1
        , "REF"=>1
        , "PREFIX_KODE"=>1
        , "VENDOR_LIS"=>1
        , "LIS_LOKASI"=>1
		, "STATUS"=>1
	];
}
