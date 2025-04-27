<?php
namespace General\V1\Rest\JenisLaporanDetil;

class JenisLaporanDetilResourceFactory
{
    public function __invoke($services)
    {
        $obj = new JenisLaporanDetilResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
