<?php
namespace General\V1\Rest\Administrasi;

class AdministrasiResourceFactory
{
    public function __invoke($services)
    {
        $obj = new AdministrasiResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
