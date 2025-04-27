<?php
namespace General\V1\Rest\JenisPesertaPenjamin;

class JenisPesertaPenjaminResourceFactory
{
    public function __invoke($services)
    {
        $obj = new JenisPesertaPenjaminResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
