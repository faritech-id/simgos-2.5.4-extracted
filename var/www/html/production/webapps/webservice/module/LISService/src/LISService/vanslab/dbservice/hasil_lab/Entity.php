<?php
namespace LISService\vanslab\dbservice\hasil_lab;
use DBService\SystemArrayObject;

class Entity extends SystemArrayObject
{
	protected $fields = [
		"no_lab"=>1, 
		"asal_lab"=>1, 
		"no_registrasi"=>1, 
		"no_rm"=>1, 
		"tgl_order"=>1, 
		"no_urut"=>1, 
		"kode_test_his"=>1, 
		"kode_test"=>1, 
		"nama_test"=>1,
		"flag" =>1, 
		"hasil"=>1, 
		"unit"=>1, 
		"nilai_normal"=>1, 
		"kode"=>1, 
		"his_test_id_order"=>1, // Penambahan field (not default)
		"status"=>1, // 0=blm di ambil his, 1=sudah di ambil
		"Created_DT"=>1
	];
}

