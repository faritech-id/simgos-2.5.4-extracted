<?php
namespace General\V1\Rest\JenisPesertaPenjamin;

use DBService\SystemArrayObject;

class JenisPesertaPenjaminEntity extends SystemArrayObject
{
	protected $fields = [
        'JENIS'=>1
        , 'ID'=>1
        , 'DESKRIPSI'=>1
        , 'STATUS'=>1
    ];
}

