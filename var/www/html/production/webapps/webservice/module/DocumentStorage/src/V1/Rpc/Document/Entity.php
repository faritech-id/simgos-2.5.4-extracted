<?php
namespace DocumentStorage\V1\Rpc\Document;

use DBService\SystemArrayObject;

class Entity extends SystemArrayObject
{
	protected $fields = [
		"ID" => 1
		, "NAME" => [
            "DESCRIPTION" => "Nama Dokumen",
            "REQUIRED" => true
        ]
		, "EXT" => [
            "DESCRIPTION" => "Ektensi File",
            "REQUIRED" => true
        ]
        , "CONTENT_TYPE" => 1
		, "LOCATION" => 1
		, "DOCUMENT_DIRECTORY_ID" => [
            "DESCRIPTION" => "Document Directory Id",
            "REQUIRED" => true
        ]
		, "DESCRIPTION" => 1
		, "CREATED_DATE" => 1
		, "CREATED_BY" => [
            "DESCRIPTION" => "Nama Lengkap dari Pengguna"
        ]
		, "UPDATED_DATE" => 1
		, "UPDATED_BY" => 1
		, "KEY" => 1
		, "REFERENCE_ID" => [
            "DESCRIPTION" => "Reference Id untuk link dokumen",
            "REQUIRED" => true
        ]
		, "REVISION_FROM" => 1
        , "FILE_LOCATION" => 1
        , "DATA" => [
            "DESCRIPTION" => "Data dari konten file di encode menggunakan base64",
            "REQUIRED" => true
        ]
	];
}
