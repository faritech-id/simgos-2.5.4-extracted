<?php
namespace General\V1\Rest\KAP;

class KAPResourceFactory
{
    public function __invoke($services)
    {
        $obj = new KAPResource();
        $obj->setServiceManager($services);
        return $obj;
    }
}
