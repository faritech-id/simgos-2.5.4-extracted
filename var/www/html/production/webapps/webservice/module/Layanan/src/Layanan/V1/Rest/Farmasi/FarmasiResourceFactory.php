<?php
namespace Layanan\V1\Rest\Farmasi;

class FarmasiResourceFactory
{
    public function __invoke($services)
    {
        $obj = new FarmasiResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
