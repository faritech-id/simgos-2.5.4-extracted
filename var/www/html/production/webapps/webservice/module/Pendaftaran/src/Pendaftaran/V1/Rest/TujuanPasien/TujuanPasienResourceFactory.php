<?php
namespace Pendaftaran\V1\Rest\TujuanPasien;

class TujuanPasienResourceFactory
{
    public function __invoke($services)
    {
        $obj = new TujuanPasienResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
