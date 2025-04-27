<?php
namespace General\V1\Rest\Instansi;

class InstansiResourceFactory
{
    public function __invoke($services)
    {
        $obj = new InstansiResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
