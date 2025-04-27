<?php
namespace Aplikasi\db\bridge_log;

use DBService\SystemArrayObject;

class Entity extends SystemArrayObject
{
    protected $fields = [
        "ID" => 1
        , "URL" => 1
        , "JENIS" => 1
        , "HEADERS" => 1
        , "TGL_REQUEST" => 1
        , "REQUEST" => 1
        , "TGL_RESPONSE" => 1
        , "RESPONSE" => 1
        , "ACCESS_FROM_IP" => 1
        , "HTTP_METHOD" => 1
        , "HTTP_STATUS_CODE" => 1
    ];
}
