<?php
namespace MedicalRecord\V1\Rest\DiagnosaKeperawatan;
use DBService\SystemArrayObject;
class DiagnosaKeperawatanEntity extends SystemArrayObject
{
    protected $fields = [
        "ID" => 1
        , "KODE" => 1
        , "DESKRIPSI" => 1
        , "STATUS" => 1
    ];
}
