<?php
namespace Pendaftaran\V1\Rest\Kunjungan;

class KunjunganResourceFactory
{
    public function __invoke($services)
    {
        $obj = new KunjunganResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
