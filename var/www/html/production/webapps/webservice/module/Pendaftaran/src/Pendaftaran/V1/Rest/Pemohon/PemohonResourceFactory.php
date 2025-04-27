<?php
namespace Pendaftaran\V1\Rest\Pemohon;

class PemohonResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PemohonResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
