<?php
namespace Pegawai\V1\Rest\KontakPegawai;

class KontakPegawaiResourceFactory
{
    public function __invoke($services)
    {
        $obj = new KontakPegawaiResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
