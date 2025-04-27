<?php
namespace MedicalRecord\V1\Rest\PenilaianBallanceCairan;

use DBService\SystemArrayObject;

class PenilaianBallanceCairanEntity extends SystemArrayObject {
    protected $fields = [
		"ID" => 1,
		"KUNJUNGAN" => 1,
		"INTAKE_ORAL" => 1,
		"INTAKE_NGT" => 1,
		"PRENTERAL" => 1,
		"PRENTERAL_JUMLAH" => 1, 
		"OBAT_INTRAVENA" => 1,
		"OBAT_INTRAVENA_JUMLAH" => 1, 
		"TRANSFUSI_PRODUK" => 1,
		"TRANSFUSI_PRODUK_JUMLAH" => 1,
		"OUTPUT_ORAL" => 1,
		"OUTPUT_NGT" => 1,
		"DRAIN" => 1,
		"DRAIN_JUMLAH" => 1,
		"URINE_WARNAH" => 1,
		"URINE_JUMLAH" => 1,
		"SPOOLING_CATHETER" => 1,
		"CAIRAN_URINE" => 1,
		"CAIRAN_SPOOLING" => 1,
		"FASES_TESKTUR" => 1,
		"FASES_WARNAH" => 1,
		"FASES_JUMLAH" => 1,
		"ULTRAFILTRASI" => 1,
		"IWL_SUHU_NORMAL" => 1,
		"IWL_KENAIKAN_SUHU" => 1,
		"TOTAL_INTAKE" => 1,
		"TOTAL_OUTPUT" => 1,
		"SKOR_BALLANCER_CAIRAN" => 1, 
		"WAKTU_PEMERIKSAAN" => 1,
		"TANGGAL" => 1,
		"OLEH" => 1,
		"STATUS" => 1
    ];
}

