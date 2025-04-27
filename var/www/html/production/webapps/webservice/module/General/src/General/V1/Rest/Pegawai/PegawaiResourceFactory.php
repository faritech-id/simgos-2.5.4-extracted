<?php
namespace General\V1\Rest\Pegawai;

class PegawaiResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PegawaiResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
