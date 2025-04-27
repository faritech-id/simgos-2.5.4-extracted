<?php
namespace General\V1\Rest\GroupPemeriksaan;
use DBService\SystemArrayObject;

class GroupPemeriksaanEntity extends SystemArrayObject
{
	protected $fields = [
        'ID'=>1,
        'JENIS'=>1,
        'KODE'=>1,
        'LEVEL'=>1,
        'DESKRIPSI'=>1,
        'STATUS'=>1
    ];
}
