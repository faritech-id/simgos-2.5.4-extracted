<?php
namespace Pendaftaran\V1\Rest\Konsul;

class KonsulResourceFactory
{
    public function __invoke($services)
    {
        $obj = new KonsulResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
