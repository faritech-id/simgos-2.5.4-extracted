<?php
namespace Layanan\V1\Rest\OrderResep;

class OrderResepResourceFactory
{
    public function __invoke($services)
    {
        $obj = new OrderResepResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
