<?php
namespace General\V1\Rest\JenisKunjunganRuangan;

class JenisKunjunganRuanganResourceFactory
{
    public function __invoke($services)
    {
        $obj = new JenisKunjunganRuanganResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
