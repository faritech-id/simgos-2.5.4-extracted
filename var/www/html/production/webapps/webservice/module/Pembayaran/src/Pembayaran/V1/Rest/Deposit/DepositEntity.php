<?php
namespace Pembayaran\V1\Rest\Deposit;
use DBService\SystemArrayObject;

class DepositEntity extends SystemArrayObject
{
	protected $fields = [
		'ID'=>1, 
		'TAGIHAN'=>1, 
		'TANGGAL'=>1, 
		'JENIS'=>1, 
		'NAMA'=>1, 
		'TOTAL'=>1, 
		'KETERANGAN'=>1, 
		'OLEH'=>1, 
		'STATUS'=>1
	];
}
