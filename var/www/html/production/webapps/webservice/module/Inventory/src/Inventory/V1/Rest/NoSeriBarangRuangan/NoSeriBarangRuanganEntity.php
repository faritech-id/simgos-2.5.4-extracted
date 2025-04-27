<?php
namespace Inventory\V1\Rest\NoSeriBarangRuangan;
use DBService\SystemArrayObject;

class NoSeriBarangRuanganEntity extends SystemArrayObject
{
	protected $fields = array(
		"ID"=>1
		, "BARANG_RUANGAN"=>1
		,"NO_SERI"=>1
		, "STATUS"=>1
		, "KONDISI_BARANG"=>1
		, "LAYAK_PAKAI"=>1
	);
}
