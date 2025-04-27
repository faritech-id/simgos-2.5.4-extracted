<?php
namespace General\V1\Rest\Referensi;

class ReferensiResourceFactory
{
    public function __invoke($services)
    {
        $obj = new ReferensiResource($services);
		$obj->setServiceManager($services);
		return $obj;
    }
}
