<?php
namespace Inventory\V1\Rest\PenerimaanBarangDetil;
use DBService\SystemArrayObject;

class PenerimaanBarangDetilEntity extends SystemArrayObject
{
	protected $fields = array(
		'ID'=>1
		, 'PENERIMAAN'=>1
		, 'BARANG'=>1
		, 'NO_BATCH'=>1
		, 'JUMLAH'=>1
		, 'BONUS'=>1
		, 'HARGA'=>1
		, 'DISKON'=>1
		, 'ONGKIR'=>1
		, 'MASA_BERLAKU'=>1
		, 'STATUS'=>1
		, 'REF_PO_DETIL' => 1
	);
}
