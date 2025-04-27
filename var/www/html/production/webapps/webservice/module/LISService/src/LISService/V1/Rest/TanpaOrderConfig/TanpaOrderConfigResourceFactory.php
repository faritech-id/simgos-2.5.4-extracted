<?php
namespace LISService\V1\Rest\TanpaOrderConfig;

class TanpaOrderConfigResourceFactory
{
    public function __invoke($services)
    {
        $obj = new TanpaOrderConfigResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
