<?php
namespace Pendaftaran\V1\Rest\JawabanKonsul;

class JawabanKonsulResourceFactory
{
    public function __invoke($services)
    {
        $obj = new JawabanKonsulResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
