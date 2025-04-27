<?php
namespace MedicalRecord\V1\Rest\IndikatorKeperawatan;
use DBService\SystemArrayObject;
class IndikatorKeperawatanEntity extends SystemArrayObject
{
    protected $fields = [
        "ID" => 1
        , "JENIS" => 1
        , "DESKRIPSI" => 1
        , "KATEGORI" => 1
        , "STATUS" => 1
    ];
}
