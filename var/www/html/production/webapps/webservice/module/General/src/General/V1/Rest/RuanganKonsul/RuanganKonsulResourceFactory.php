<?php
namespace General\V1\Rest\RuanganKonsul;

class RuanganKonsulResourceFactory
{
    public function __invoke($services)
    {
        $obj = new RuanganKonsulResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
