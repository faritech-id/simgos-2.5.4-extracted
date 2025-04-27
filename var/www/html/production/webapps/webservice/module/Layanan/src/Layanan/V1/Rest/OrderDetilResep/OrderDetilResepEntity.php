<?php
namespace Layanan\V1\Rest\OrderDetilResep;
use DBService\SystemArrayObject;

class OrderDetilResepEntity extends SystemArrayObject
{
	protected $fields = [
		'ORDER_ID'=>1, 
		'FARMASI'=>1, 
		'JUMLAH'=>1,
		'DOSIS'=>1,
		'ATURAN_PAKAI'=>1, 
		'KETERANGAN'=>1, 
		'RACIKAN'=>1, 
		'GROUP_RACIKAN'=>1,
		'PETUNJUK_RACIKAN'=>1, 
		'JUMLAH_RACIKAN'=>1, 
		'REF'=>1,
		'FREKUENSI'=>1,
		'RUTE_PEMBERIAN'=>1,
		'STATUS_PEMBERIAN'=>1,
		'REF_RIWAYAT_ORDER'=>1,
		'TANGGAL_STOP'=>1,
		'USER_STOP'=>1,
		'TINDAKAN_PAKET'=>1,
		'TINDAKAN'=>1
	];
}
