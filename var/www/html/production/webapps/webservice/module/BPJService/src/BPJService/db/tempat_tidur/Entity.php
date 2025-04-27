<?php
namespace BPJService\db\tempat_tidur;

use DBService\SystemArrayObject;

class Entity extends SystemArrayObject
{
	protected $fields = array(
		"id" => 1
        , "kodekelas" => 1
        , "koderuang" => 1
        , "namaruang" => 1
        , "kapasitas" => 1
        , "tersedia" => 1
        , "tersediapria" => 1
        , "tersediawanita" => 1
        , "tersediapriawanita" => 1
        , "tanggal_updated" => 1
        , "ruang_baru" => 1
        , "hapus_ruang" => 1
        , "kirim" => 1
	);
}
