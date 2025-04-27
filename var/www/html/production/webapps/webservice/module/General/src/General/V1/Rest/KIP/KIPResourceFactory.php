<?php
namespace General\V1\Rest\KIP;

class KIPResourceFactory
{
    public function __invoke($services)
    {
        $obj = new KIPResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
