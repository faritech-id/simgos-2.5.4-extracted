<?php
namespace Layanan\V1\Rest\BatasLayananObat;

class BatasLayananObatResourceFactory
{
    public function __invoke($services)
    {
        $obj = new BatasLayananObatResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
