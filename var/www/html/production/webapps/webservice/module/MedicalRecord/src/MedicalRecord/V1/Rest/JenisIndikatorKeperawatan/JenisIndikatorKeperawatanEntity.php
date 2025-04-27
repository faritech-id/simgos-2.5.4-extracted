<?php
namespace MedicalRecord\V1\Rest\JenisIndikatorKeperawatan;
use DBService\SystemArrayObject;
class JenisIndikatorKeperawatanEntity extends SystemArrayObject
{
    protected $fields = [
        "ID" => 1
        , "DESKRIPSI" => 1
        , "STATUS" => 1
    ];
}
