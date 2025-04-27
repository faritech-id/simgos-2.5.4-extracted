<?php
namespace General\V1\Rest\DiagnosaMasuk;

class DiagnosaMasukResourceFactory
{
    public function __invoke($services)
    {
        $obj = new DiagnosaMasukResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
