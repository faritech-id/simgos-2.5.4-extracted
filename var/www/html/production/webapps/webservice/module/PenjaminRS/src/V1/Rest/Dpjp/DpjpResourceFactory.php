<?php
namespace PenjaminRS\V1\Rest\Dpjp;

class DpjpResourceFactory
{
    public function __invoke($services)
    {
        $obj = new DpjpResource($services);
		$obj->setServiceManager($services);
		return $obj;
    }
}
