<?php
namespace General\V1\Rest\JenisLaporan;

class JenisLaporanResourceFactory
{
    public function __invoke($services)
    {
        $obj = new JenisLaporanResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
