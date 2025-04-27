<?php
namespace Layanan\V1\Rest\OrderDetilLab;

class OrderDetilLabResourceFactory
{
    public function __invoke($services)
    {
        $obj = new OrderDetilLabResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
