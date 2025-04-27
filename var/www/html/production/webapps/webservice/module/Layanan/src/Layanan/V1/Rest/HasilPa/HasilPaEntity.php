<?php
namespace Layanan\V1\Rest\HasilPa;
use DBService\SystemArrayObject;

class HasilPaEntity extends SystemArrayObject
{
	protected $fields = [
		'ID'=>1, 
		'KUNJUNGAN'=>[
			"REQUIRED" => true
		],
		'JENIS_PEMERIKSAAN'=>[
			"REQUIRED" => true
		],
		'NOMOR_PA'=>1, 
		'PA_SEBELUMNYA'=>1, 
		'JARINGAN'=>1, 
		'PERMINTAAN_IHC'=>1, 
		'ASISTEN'=>1, 
		'LOKASI'=>1, 
		'DIDAPAT_DENGAN'=>1, 
		'CAIRAN_FIKSASI'=>1, 
		'DIAGNOSA_KLINIK'=>1, 
		'KETERANGAN_KLINIK'=>1, 
		'MAKROSKOPIK'=>1, 
		'MIKROSKOPIK'=>1, 
		'KESIMPULAN'=>1,
		'IMUNO_HISTOKIMIA'=>1,
		'REEVALUASI'=>1,
		'TANGGAL_IMUNO'=>1,
		'DOKTER'=>1,
		'TANGGAL'=>1,
		'OLEH'=>1,
		'STATUS'=>1
	];
}
