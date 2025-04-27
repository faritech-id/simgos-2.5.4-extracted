<?php
namespace Pendaftaran\V1\Rest\RujukanKeluar;

class RujukanKeluarResourceFactory
{
    public function __invoke($services)
    {
        $obj = new RujukanKeluarResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
