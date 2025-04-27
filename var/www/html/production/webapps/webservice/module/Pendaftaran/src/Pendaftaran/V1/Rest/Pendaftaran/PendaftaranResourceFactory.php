<?php
namespace Pendaftaran\V1\Rest\Pendaftaran;

class PendaftaranResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PendaftaranResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
