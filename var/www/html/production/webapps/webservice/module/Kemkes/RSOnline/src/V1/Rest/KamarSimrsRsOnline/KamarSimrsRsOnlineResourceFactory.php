<?php
namespace Kemkes\RSOnline\V1\Rest\KamarSimrsRsOnline;

class KamarSimrsRsOnlineResourceFactory
{
    public function __invoke($services)
    {
        $obj = new KamarSimrsRsOnlineResource();
    	$obj->setServiceManager($services);
        return $obj;
    }
}
