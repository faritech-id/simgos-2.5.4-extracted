<?php
namespace Kemkes\RSOnline\V1\Rest\DataKebutuhanSDM;

use DBService\SystemArrayObject;

class DataKebutuhanSDMEntity extends SystemArrayObject
{
	protected $fields = [
		"id_kebutuhan" => 1
        , "jumlah_eksisting" => 1
        , "jumlah" => 1
        , 'jumlah_diterima' => 1
        , 'baru' => 1
        , 'tgl_kirim' => 1
        , 'kirim' => 1
        , 'response' => 1
	];
}
