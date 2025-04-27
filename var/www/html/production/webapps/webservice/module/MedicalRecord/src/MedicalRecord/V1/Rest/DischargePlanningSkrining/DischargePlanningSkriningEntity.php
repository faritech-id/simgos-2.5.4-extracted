<?php
namespace MedicalRecord\V1\Rest\DischargePlanningSkrining;

use DBService\SystemArrayObject;

class DischargePlanningSkriningEntity extends SystemArrayObject
{
	protected $fields = [
		"ID"=>1
		, "KUNJUNGAN"=>1
		, "KEBUTUHAN_PELAYANAN_BERKELANJUTAN_KPB"=>1
		, "KPB_RAWAT_LUKA"=>1
		, "KPB_HIV"=>1
		, "KPB_TB"=>1
		, "KPB_DM"=>1
		, "KPB_DM_TERAPI_INSULIN"=>1
		, "KPB_STROKE"=>1
		, "KPB_PPOK"=>1
		, "KPB_CKD"=>1		
		, "KPB_PASIEN_KEMO"=>1
		, "PENGGUNAAN_ALAT_MEDIS_PAM"=>1
		, "PAM_KATETER_URIN"=>1
		, "PAM_NGT"=>1
		, "PAM_TRAECHOSTOMY"=>1
		, "PAM_COLOSTOMY"=>1
		, "PAM_LAINNYA"=>1
		, "TANGGAL"=>1
		, "OLEH"=>1
		, "STATUS"=>1
    ];
}