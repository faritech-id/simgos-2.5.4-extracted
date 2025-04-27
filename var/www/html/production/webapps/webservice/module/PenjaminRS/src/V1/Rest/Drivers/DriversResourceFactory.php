<?php
namespace PenjaminRS\V1\Rest\Drivers;

class DriversResourceFactory
{
    public function __invoke($services)
    {
        $obj = new DriversResource($services);
		$obj->setServiceManager($services);
		return $obj;
    }
}
