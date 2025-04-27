<?php
namespace INACBGService\db\dokumen_pendukung;
use DBService\SystemArrayObject;

class Entity extends SystemArrayObject
{
	protected $fields = [
		"id" => 1
		, "no_klaim" => 1
		, "file_id" => 1
		, "file_class" => 1
		, "file_name" => 1
		, "file_size" => 1
		, "file_type" => 1
		, "file_content" => 1
		, "kirim_bpjs" => 1
		, "document_id" => 1
		, "tanggal" => 1
		, "oleh" => 1
		, "status" => 1	
    ];
}
