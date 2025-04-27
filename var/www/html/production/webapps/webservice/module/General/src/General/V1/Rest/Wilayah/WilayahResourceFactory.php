<?php
namespace General\V1\Rest\Wilayah;

class WilayahResourceFactory
{
    public function __invoke($services)
    {
        $obj = new WilayahResource($services);
		$obj->setServiceManager($services);
		return $obj;
    }
}
