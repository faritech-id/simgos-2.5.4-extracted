<?php
namespace Layanan\V1\Rest\Farmasi;
use DBService\SystemArrayObject;

class FarmasiEntity extends SystemArrayObject
{
	protected $fields = [
		'ID'=>1, 
		'KUNJUNGAN'=>1, 
		'FARMASI'=>1, 
		'TANGGAL'=>1, 
		'JUMLAH'=>1, 
		'BON'=>1, 
		'ATURAN_PAKAI'=>1, 
		'SIGNA1'=>1, 
		'SIGNA2'=>1, 
		'DOSIS'=>1, 
		'KETERANGAN'=>1,
		'RACIKAN'=>1, 
		'GROUP_RACIKAN'=>1,
		'ALASAN_TIDAK_TERLAYANI'=>1,
		'HARI'=>1,
		'KLAIM_TERPISAH'=>1,
		'TINDAKAN_PAKET'=>1,
		'FREKUENSI'=>1,
		'RUTE_PEMBERIAN'=>1,
		'OLEH'=>1, 
		'STATUS'=>1, 
		'REF'=>1,
		'TINDAKAN'=>1
	];
}
