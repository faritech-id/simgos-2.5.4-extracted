<?php
namespace Pembayaran\V1\Rest\TagihanKlaim;
use DBService\SystemArrayObject;

class TagihanKlaimEntity extends SystemArrayObject
{
    protected $fields = [
		'ID'=>1,
        'TAGIHAN'=>1,
        'NORM'=>1,
        'NOPEN'=>1,
        'MASUK'=>1,
        'KELUAR'=>1,
        'TANGGAL_FINAL'=>1,
        'PENJAMIN'=>1,
        'JENIS'=>1,
        'TOTAL'=>1,
        'STATUS'=>1
	];
}
