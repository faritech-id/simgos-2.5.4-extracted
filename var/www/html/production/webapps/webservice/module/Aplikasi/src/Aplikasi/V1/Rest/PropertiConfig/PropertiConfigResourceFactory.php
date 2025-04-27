<?php
namespace Aplikasi\V1\Rest\PropertiConfig;

class PropertiConfigResourceFactory
{
    public function __invoke($services)
    {
        $obj = new PropertiConfigResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
