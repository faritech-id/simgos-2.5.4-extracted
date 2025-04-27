<?php
namespace General\V1\Rest\Rekening;

class RekeningResourceFactory
{
    public function __invoke($services)
    {
        $obj = new RekeningResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
