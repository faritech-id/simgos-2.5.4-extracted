<?php
namespace LISService\V1\Rest\MappingHasil;

use DBService\SystemArrayObject;

class MappingHasilEntity extends SystemArrayObject
{
    protected $fields = [
		    "ID"=>1, 
        "VENDOR_LIS"=>1, 
        "LIS_KODE_TEST"=>1,
        "PREFIX_KODE"=>1,
        "HIS_KODE_TEST"=>1,
        "PARAMETER_TINDAKAN_LAB"=>1
	  ];
}
