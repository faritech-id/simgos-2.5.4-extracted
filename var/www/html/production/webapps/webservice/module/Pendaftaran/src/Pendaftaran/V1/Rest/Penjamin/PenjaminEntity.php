<?php
namespace Pendaftaran\V1\Rest\Penjamin;
use DBService\SystemArrayObject;

class PenjaminEntity extends SystemArrayObject
{
	protected $fields = [
	    'JENIS' => 1
	    , 'NOPEN' => 1
	    , 'NOMOR' => 1
		, 'KELAS' => 1
		, 'JENIS_PESERTA' => 1
	    , 'COB' => 1
	    , 'KATARAK' => 1
	    , 'NO_SURAT' => 1
	    , 'DPJP' => 1
		, 'NAIK_KELAS' => 1
		, 'PEMBIAYAAN' => 1
		, 'PENANGGUNGJAWAB' => 1
		, 'TUJUAN_KUNJUNGAN' => 1
		, 'PROCEDURE' => 1
		, 'PENUNJANG' => 1
		, 'ASSESMENT_PELAYANAN' => 1
		, 'DPJP_LAYANAN' => 1
	    , 'CATATAN' => 1
	];
}
