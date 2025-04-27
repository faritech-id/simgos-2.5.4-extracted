<?php
namespace General\V1\Rest\FrekuensiAturanResep;

class FrekuensiAturanResepResourceFactory
{
    public function __invoke($services)
    {
        $obj = new FrekuensiAturanResepResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
