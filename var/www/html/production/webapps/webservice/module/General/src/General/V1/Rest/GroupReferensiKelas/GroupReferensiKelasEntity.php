<?php
namespace General\V1\Rest\GroupReferensiKelas;

use DBService\SystemArrayObject;

class GroupReferensiKelasEntity extends SystemArrayObject
{
    protected $fields = array(
		"ID" => 1
        , "REFERENSI_KELAS" => 1
        , "KELAS" => 1
	);
}
