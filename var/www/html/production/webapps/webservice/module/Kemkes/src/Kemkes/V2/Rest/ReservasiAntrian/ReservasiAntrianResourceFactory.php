<?php
namespace Kemkes\V2\Rest\ReservasiAntrian;

class ReservasiAntrianResourceFactory
{
    public function __invoke($services)
    {
        $obj = new ReservasiAntrianResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
