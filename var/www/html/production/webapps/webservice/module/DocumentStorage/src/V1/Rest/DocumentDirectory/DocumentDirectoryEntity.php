<?php
namespace DocumentStorage\V1\Rest\DocumentDirectory;

use DBService\SystemArrayObject;

class DocumentDirectoryEntity extends SystemArrayObject
{
    protected $fields = [
		"ID" => 1
		, "DOCUMENT_NAME" => [
            "DESCRIPTION" => "Nama Dokumen",
            "REQUIRED" => true
        ]
		, "DIRECTORY" => 1
	];
}
