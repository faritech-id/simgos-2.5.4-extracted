<?php
namespace General\V1\Rest\RuanganLayananFarmasi;
use DBService\SystemArrayObject;

class RuanganLayananFarmasiEntity extends SystemArrayObject
{
	protected $fields = array('ID'=>1, 'RUANGAN_KUNJUNGAN'=>1, 'RUANGAN_LAYANAN'=>1, 'JAM_AWAL'=>1, 'JAM_AKHIR'=>1, 'STATUS'=>1, 'OLEH'=>1);
}
