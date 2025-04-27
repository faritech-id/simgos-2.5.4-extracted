<?php
namespace General\V1\Rest\JenisReferensi;

class JenisReferensiResourceFactory
{
    public function __invoke($services)
    {
        $obj = new JenisReferensiResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
