<?php
namespace General\V1\Rest\Negara;

class NegaraResourceFactory
{
    public function __invoke($services)
    {
        $obj = new NegaraResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
