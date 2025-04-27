<?php
namespace INACBGService\V1\Rest\Inacbg;

class InacbgResourceFactory
{
    public function __invoke($services)
    {
        $obj = new InacbgResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
