<?php
namespace General\V1\Rest\MappingGroupPemeriksaan;
use DBService\SystemArrayObject;

class MappingGroupPemeriksaanEntity extends SystemArrayObject
{
	protected $fields = [
        'ID'=>1,
        'GROUP_PEMERIKSAAN_ID' => [
            "DESCRIPTION" => "Id Group Pemeriksaan",
			"REQUIRED" => true
		], 
        'PEMERIKSAAN' => [
            "DESCRIPTION" => "Id Pemeriksaan",
			"REQUIRED" => true
		], 
        'STATUS'=>1
    ];
}

