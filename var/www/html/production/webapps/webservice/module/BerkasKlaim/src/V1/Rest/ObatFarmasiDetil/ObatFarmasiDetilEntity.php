<?php
namespace BerkasKlaim\V1\Rest\ObatFarmasiDetil;
use DBService\SystemArrayObject;

class ObatFarmasiDetilEntity extends SystemArrayObject
{
	protected $fields = [
		"ID"=>1
		, "OBAT_FARMASI"=>1
		, "KUNJUNGAN"=>1
		, "STATUS"=>1
	];
}
