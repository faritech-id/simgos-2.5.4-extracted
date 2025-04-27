<?php
namespace INACBGService\V1\Rest\HasilGrouping;
use DBService\SystemArrayObject;

class HasilGroupingEntity extends SystemArrayObject
{
	protected $fields = [
		'NOPEN'=>1
		, "TAGIHAN_ID"=>1
		, 'NOSEP'=>1
		, 'CODECBG'=>1
		, 'TARIFCBG'=>1
		, 'TARIFSP'=>1
		, 'TARIFSR'=>1
		, 'TARIFSI'=>1
		, 'TARIFSD'=>1
		, 'TARIFSA'=>1
		, 'TARIFSC'=>1
		, 'TARIFKLS1'=>1
		, 'TARIFKLS2'=>1
		, 'TARIFKLS3'=>1
		, 'TOTALTARIF'=>1
		, 'TARIFRS'=>1
		, 'UNUSR'=>1
		, 'UNUSI'=>1
		, 'UNUSP'=>1
		, 'UNUSD'=>1
		, 'UNUSA'=>1
		, 'UNUSC'=>1
		, 'TANGGAL'=>1
		, 'USER'=>1
		, 'STATUS'=>1
		, 'TIPE'=>1
		, 'DC_KEMKES'=>1
		, 'DC_BPJS'=>1
		, 'POST_DATA'=>1
		, 'RESPONSE'=>1
		, 'INA_GROUPER_MDC_NUMBER'=>1
		, 'INA_GROUPER_MDC_DESCRIPTION'=>1
		, 'INA_GROUPER_DRG_CODE'=>1
		, 'INA_GROUPER_DRG_DESCRIPTION'=>1
		, "TOP_UP_RAWAT_GROSS" => 1
		, "TOP_UP_RAWAT_FACTOR" => 1
		, "TOP_UP_RAWAT" => 1
		, "TOP_UP_JENAZAH" => 1
		, "COVID_19_DESCRIPTION" => 1
		, "KLAIM" => 1
	];
}
