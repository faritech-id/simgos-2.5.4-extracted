<?php
namespace Pendaftaran\V1\Rest\Penjamin;

class PenjaminResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PenjaminResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
