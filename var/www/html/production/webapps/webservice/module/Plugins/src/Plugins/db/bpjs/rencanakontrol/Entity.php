<?php
namespace Plugins\db\bpjs\rencanakontrol;

use DBService\SystemArrayObject;

class Entity extends SystemArrayObject
{
    protected $fields = array(
        "jnsKontrol" => 1
        , "jnsPelayanan" => 1
        , "kodeDokter" => 1
        , "nama" => 1
        , "namaDokter" => 1
        , "namaJnsKontrol" => 1
        , "namaPoliAsal" => 1
        , "noKartu" => 1
        , "noSepAsalKontrol" => 1
        , "noSuratKontrol" => 1
        , "nomorreferensi" => 1
        , "poliAsal" => 1
        , "poliTujuan" => 1
        , "terbitSEP" => 1
        , "tglRencanaKontrol" => 1
        , "tglTerbitKontrol" => 1
    );
}