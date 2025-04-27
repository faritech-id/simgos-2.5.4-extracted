<?php
namespace Pegawai\V1\Rest\KartuIdentitas;

class KartuIdentitasResourceFactory
{
    public function __invoke($services)
    {
        $obj = new KartuIdentitasResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
