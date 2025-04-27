<?php
namespace BerkasKlaim\V1\Rest\ObatFarmasi;
use DBService\SystemArrayObject;

class ObatFarmasiEntity extends SystemArrayObject
{
	protected $fields = [
		"ID"=>1
		, "PENDAFTARAN"=>1
		, "NOSEP"=>1
		, "TANGGAL"=>1
		, "OLEH"=>1
		, "STATUS"=>1
	];
}
