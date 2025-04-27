<?php
namespace Aplikasi\db\request_report;

use DBService\SystemArrayObject;

class Entity extends SystemArrayObject
{
    protected $fields = [
        "ID" => 1
        , "DOCUMENT_STORAGE_ID" => 1
        , "KEY" => 1
        , "REQUEST_DATA" => 1
        , "DOCUMENT_DIRECTORY_ID" => 1
        , "REF_ID" => 1
        , "DIBUAT_TANGGAL" => 1
        , "DIBUAT_OLEH" => 1
        , "DIUBAH_TANGGAL" => 1
        , "DIUBAH_OLEH" => 1
        , "TTD_OLEH" => 1
        , "TTD_TANGGAL" => 1
        , "STATUS" => 1
    ];
}
